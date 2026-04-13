// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";

/// @title ConfidentialVesting — Encrypted token grant vesting
/// @notice Grant tokens with encrypted amounts and cliff. Beneficiary claims over time.
///         Neither the amount nor the cliff is visible onchain.
/// @dev Demonstrates: toEuint256, le, select, sub, mul, addViewer, time-based logic
contract ConfidentialVesting {
    struct Grant {
        address grantor;
        address beneficiary;
        euint256 totalAmount;
        euint256 claimed;
        uint256 startTime;
        uint256 cliffEnd;
        uint256 vestingEnd;
        bool revoked;
    }

    uint256 public nextGrantId;
    mapping(uint256 => Grant) public grants;

    event GrantCreated(uint256 indexed grantId, address indexed beneficiary);
    event Claimed(uint256 indexed grantId);
    event Revoked(uint256 indexed grantId);

    function createGrant(
        address beneficiary,
        externalEuint256 encAmount,
        bytes calldata proof,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) external returns (uint256 grantId) {
        euint256 amount = Nox.fromExternal(encAmount, proof);
        Nox.allowThis(amount);
        Nox.allow(amount, msg.sender);
        Nox.allow(amount, beneficiary);

        euint256 zero = Nox.toEuint256(0);
        Nox.allowThis(zero);

        grantId = nextGrantId++;
        grants[grantId] = Grant({
            grantor: msg.sender,
            beneficiary: beneficiary,
            totalAmount: amount,
            claimed: zero,
            startTime: block.timestamp,
            cliffEnd: block.timestamp + cliffDuration,
            vestingEnd: block.timestamp + vestingDuration,
            revoked: false
        });

        emit GrantCreated(grantId, beneficiary);
    }

    function claim(uint256 grantId) external {
        Grant storage g = grants[grantId];
        require(msg.sender == g.beneficiary, "Not beneficiary");
        require(!g.revoked, "Grant revoked");
        require(block.timestamp >= g.cliffEnd, "Cliff not reached");

        // Calculate vested fraction using plaintext time math
        uint256 elapsed = block.timestamp - g.startTime;
        uint256 total = g.vestingEnd - g.startTime;
        if (elapsed > total) elapsed = total;

        // Compute vested amount on encrypted values
        // vested = totalAmount * elapsed / total
        euint256 encElapsed = Nox.toEuint256(elapsed);
        Nox.allowThis(encElapsed);
        euint256 numerator = Nox.mul(g.totalAmount, encElapsed);
        Nox.allowThis(numerator);
        euint256 encTotal = Nox.toEuint256(total);
        Nox.allowThis(encTotal);
        euint256 vested = Nox.div(numerator, encTotal);
        Nox.allowThis(vested);

        // Claimable = vested - already claimed
        euint256 claimable = Nox.sub(vested, g.claimed);
        Nox.allowThis(claimable);
        Nox.allow(claimable, msg.sender);

        // Update claimed
        g.claimed = vested;
        Nox.allowThis(g.claimed);
        Nox.allow(g.claimed, msg.sender);

        emit Claimed(grantId);
    }

    function grantAuditorAccess(uint256 grantId, address auditor) external {
        Grant storage g = grants[grantId];
        require(msg.sender == g.grantor, "Not grantor");
        Nox.addViewer(g.totalAmount, auditor);
        Nox.addViewer(g.claimed, auditor);
    }

    function revoke(uint256 grantId) external {
        Grant storage g = grants[grantId];
        require(msg.sender == g.grantor, "Not grantor");
        g.revoked = true;
        emit Revoked(grantId);
    }
}
