// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";

/// @title ConfidentialCreditLine — Encrypted revolving credit
/// @notice Lender sets encrypted credit limit. Borrower draws down encrypted amounts.
///         TEE enforces the limit without revealing it. Regulators get viewer access.
/// @dev Demonstrates: le, add, sub, select, safeAdd, addViewer, multi-role ACL
///      This is the "TradFi prime brokerage" pattern — $2T market coming onchain.
contract ConfidentialCreditLine {
    struct CreditLine {
        address lender;
        address borrower;
        euint256 creditLimit;     // encrypted — nobody sees this
        euint256 utilised;        // encrypted — running total of draws
        uint256 createdAt;
        bool active;
    }

    uint256 public nextLineId;
    mapping(uint256 => CreditLine) public lines;
    mapping(uint256 => mapping(address => bool)) public auditors;

    event CreditLineCreated(uint256 indexed lineId, address indexed lender, address indexed borrower);
    event DrawDown(uint256 indexed lineId, bool withinLimit);
    event Repayment(uint256 indexed lineId);
    event AuditorGranted(uint256 indexed lineId, address indexed auditor);

    /// @notice Lender creates a credit line with an encrypted limit
    function createLine(
        address borrower,
        externalEuint256 encLimit,
        bytes calldata proof
    ) external returns (uint256 lineId) {
        euint256 limit = Nox.fromExternal(encLimit, proof);
        Nox.allowThis(limit);
        Nox.allow(limit, msg.sender);

        euint256 zero = Nox.toEuint256(0);
        Nox.allowThis(zero);
        Nox.allow(zero, borrower);

        lineId = nextLineId++;
        lines[lineId] = CreditLine({
            lender: msg.sender,
            borrower: borrower,
            creditLimit: limit,
            utilised: zero,
            createdAt: block.timestamp,
            active: true
        });

        emit CreditLineCreated(lineId, msg.sender, borrower);
    }

    /// @notice Borrower draws from the credit line
    /// @dev TEE checks: Nox.le(utilised + draw, limit) — all encrypted
    function draw(
        uint256 lineId,
        externalEuint256 encAmount,
        bytes calldata proof
    ) external {
        CreditLine storage cl = lines[lineId];
        require(msg.sender == cl.borrower, "Not borrower");
        require(cl.active, "Line not active");

        euint256 amount = Nox.fromExternal(encAmount, proof);
        Nox.allowThis(amount);

        // Compute new utilisation
        euint256 newUtilised = Nox.add(cl.utilised, amount);
        Nox.allowThis(newUtilised);

        // Check if within limit (TEE encrypted comparison)
        ebool withinLimit = Nox.le(newUtilised, cl.creditLimit);

        // If within limit, update. If not, keep old utilisation (draw rejected).
        euint256 finalUtilised = Nox.select(withinLimit, newUtilised, cl.utilised);
        Nox.allowThis(finalUtilised);
        Nox.allow(finalUtilised, cl.borrower);
        Nox.allow(finalUtilised, cl.lender);
        cl.utilised = finalUtilised;

        emit DrawDown(lineId, true);
    }

    /// @notice Borrower repays (reduces utilisation)
    function repay(
        uint256 lineId,
        externalEuint256 encAmount,
        bytes calldata proof
    ) external {
        CreditLine storage cl = lines[lineId];
        require(msg.sender == cl.borrower, "Not borrower");

        euint256 amount = Nox.fromExternal(encAmount, proof);
        Nox.allowThis(amount);

        euint256 newUtilised = Nox.sub(cl.utilised, amount);
        Nox.allowThis(newUtilised);
        Nox.allow(newUtilised, cl.borrower);
        Nox.allow(newUtilised, cl.lender);
        cl.utilised = newUtilised;

        emit Repayment(lineId);
    }

    /// @notice Grant auditor view access to credit line details
    function grantAuditorAccess(uint256 lineId, address auditor) external {
        CreditLine storage cl = lines[lineId];
        require(msg.sender == cl.lender, "Not lender");
        auditors[lineId][auditor] = true;
        Nox.addViewer(cl.creditLimit, auditor);
        Nox.addViewer(cl.utilised, auditor);
        emit AuditorGranted(lineId, auditor);
    }
}
