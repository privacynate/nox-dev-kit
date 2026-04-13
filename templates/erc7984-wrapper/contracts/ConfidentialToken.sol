// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC7984} from "@iexec-nox/nox-confidential-contracts/contracts/token/ERC7984.sol";
import {ERC20ToERC7984Wrapper} from "@iexec-nox/nox-confidential-contracts/contracts/token/extensions/ERC20ToERC7984Wrapper.sol";

/// @title ConfidentialToken — Wrap any ERC-20 into ERC-7984
/// @notice Wraps a standard ERC-20 into a confidential token with hidden balances.
///         Demonstrates: ERC-7984, wrap/unwrap, operator pattern, confidentialTransfer.
/// @dev Constructor order matters: ERC20ToERC7984Wrapper THEN ERC7984
contract ConfidentialToken is ERC20ToERC7984Wrapper {
    constructor(address underlying_)
        ERC20ToERC7984Wrapper(IERC20(underlying_))
        ERC7984("Confidential Token", "cTOKEN", "") {}
}
