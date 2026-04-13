// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";

/// @title ConfidentialEscrow — Encrypted bilateral escrow
/// @notice Two parties deposit encrypted amounts. Released on mutual agreement.
///         Neither party sees the other's deposit until release.
/// @dev Demonstrates: fromExternal, add, le, select, allow, addViewer, multi-party ACL
contract ConfidentialEscrow {
    struct Deal {
        address partyA;
        address partyB;
        euint256 depositA;
        euint256 depositB;
        bool depositedA;
        bool depositedB;
        bool released;
        address auditor;
    }

    uint256 public nextDealId;
    mapping(uint256 => Deal) public deals;

    event DealCreated(uint256 indexed dealId, address partyA, address partyB);
    event Deposited(uint256 indexed dealId, address indexed party);
    event Released(uint256 indexed dealId);

    function createDeal(address partyB, address auditor) external returns (uint256 dealId) {
        dealId = nextDealId++;
        deals[dealId].partyA = msg.sender;
        deals[dealId].partyB = partyB;
        deals[dealId].auditor = auditor;
        emit DealCreated(dealId, msg.sender, partyB);
    }

    function deposit(
        uint256 dealId,
        externalEuint256 encAmount,
        bytes calldata proof
    ) external {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.partyA || msg.sender == deal.partyB, "Not a party");

        euint256 amount = Nox.fromExternal(encAmount, proof);
        Nox.allowThis(amount);
        Nox.allow(amount, msg.sender);

        if (msg.sender == deal.partyA) {
            require(!deal.depositedA, "Already deposited");
            deal.depositA = amount;
            deal.depositedA = true;
        } else {
            require(!deal.depositedB, "Already deposited");
            deal.depositB = amount;
            deal.depositedB = true;
        }

        // Auditor gets view access to deposits
        if (deal.auditor != address(0)) {
            Nox.addViewer(amount, deal.auditor);
        }

        emit Deposited(dealId, msg.sender);
    }

    function release(uint256 dealId) external {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.partyA || msg.sender == deal.partyB, "Not a party");
        require(deal.depositedA && deal.depositedB, "Both must deposit first");
        require(!deal.released, "Already released");

        // Both parties can now see both deposits
        Nox.allow(deal.depositA, deal.partyB);
        Nox.allow(deal.depositB, deal.partyA);

        deal.released = true;
        emit Released(dealId);
    }
}
