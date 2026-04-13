# iExec Nox Protocol — Agent Integration Guide

This file helps AI coding agents (Claude, Cursor, Windsurf, Codex, Aider) write correct iExec Nox confidential smart contracts.

For the full reference, see CLAUDE.md in this project.

## Quick Rules

1. `pragma solidity ^0.8.28;`
2. Import: `import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";`
3. After EVERY Nox operation → call `Nox.allowThis(result)`
4. For every address that needs to read → call `Nox.allow(result, address)` or `Nox.addViewer(result, address)`
5. Encrypted inputs are bound to the target contract address. Cannot relay through intermediaries.
6. Use `Nox.select(ebool, ifTrue, ifFalse)` instead of `if` statements on encrypted values.
7. Network: Arbitrum Sepolia (chain ID 421614). Hardhat 3 with `type: "http"` in network config.
8. Node.js ≥ 22, pnpm ≥ 10, `"type": "module"` in package.json.

## Decision Tree

- Need encrypted arithmetic? → `Nox.add/sub/mul/div` + `Nox.allowThis`
- Need to compare encrypted values? → `Nox.le/ge/eq` → returns `ebool`
- Need conditional logic on encrypted? → `Nox.select(ebool, a, b)`
- Need overflow protection? → `Nox.safeAdd/safeSub` → returns `(ebool, euint256)`
- Need to let someone decrypt? → `Nox.allow` (admin) or `Nox.addViewer` (read-only)
- Need to convert plaintext → encrypted? → `Nox.toEuint256(value)`
- Need to accept user-encrypted input? → `Nox.fromExternal(handle, proof)` with `externalEuint256` parameter type

## Anti-Patterns (NEVER do these)

- Never use `if` on `ebool` — use `Nox.select`
- Never forget `allowThis` after Nox computation
- Never relay encrypted inputs through intermediary contracts
- Never mix `nox-protocol-contracts` versions (beta.7 ≠ beta.9)
- Never use `gasPrice` on Arbitrum (use `maxFeePerGas` + `maxPriorityFeePerGas`)
