# Feedback on iExec Nox Developer Tools

## Context

We built two projects during the iExec Vibe Coding Challenge:
1. **NoxTreasury** — a confidential corporate treasury app
2. **nox-dev-kit** — a community starter kit for building on Nox

This feedback comes from 20+ hours of hands-on development with Nox Protocol, ERC-7984, and the Handle SDK.

## What Works Well

### 1. Nox SDK Design
The `Nox.sol` library is elegantly designed. The pattern of `uint256 → euint256` with `Nox.add()`, `Nox.le()`, `Nox.select()` feels natural for Solidity developers. The learning curve is low once you understand the handle model.

### 2. Handle SDK
`@iexec-nox/handle` provides a clean API. `encryptInput()` and `decrypt()` work seamlessly with both ethers.js and viem. The EIP-712 signature flow for decryption is well-designed.

### 3. ERC-7984 Standard
The operator model (time-bound, no amount) is simpler than ERC-20 allowances and better suited for encrypted systems. The `ERC20ToERC7984Wrapper` makes wrapping trivial.

### 4. Gas Efficiency
Nox operations are genuinely cheaper than alternatives. The 35-85% savings vs Zama fhEVM are a real differentiator, especially for composite operations.

## Critical Issues

### 1. Version Compatibility (Blocker)
`@iexec-nox/nox-confidential-contracts@0.1.0-beta.2` depends on `nox-protocol-contracts@0.1.0-beta.7`, but the Handle SDK expects beta.9 handle format. This causes `Handle chainId does not match` errors that take hours to debug.

**Fix:** Peer dependency constraints or a compatibility matrix in the docs.

**Our workaround:** pnpm overrides to force beta.9 everywhere.

### 2. No Hardhat/Foundry Integration Guide
The docs say "Coming Soon" for both. Since Hardhat 3 is required and has breaking changes (ESM-only, `type: "http"` network config, Node.js 22+), this is a major friction point.

**What we built:** A pre-configured `hardhat.config.ts` in nox-dev-kit that works out of the box.

### 3. Encrypted Inputs Are Contract-Bound
`Nox.fromExternal()` validates that the encrypted input proof was created for `address(this)`. This means you cannot relay encrypted inputs through intermediary contracts. This is architecturally correct but **completely undocumented** and took us 4 hours to discover.

**Impact:** Any "middleware" pattern (compliance check → then transfer) requires the user to encrypt the value TWICE — once per target contract. This needs a prominent warning in the docs.

### 4. Missing Frontend Integration Examples
No example exists of how to wire Nox into a React/Next.js app with wagmi/viem. Frontend developers need:
- How to create a Handle Client in the browser
- How to call encrypted functions via wagmi's `useWriteContract`
- Gas estimation patterns for Arbitrum Sepolia (EIP-1559)

**What we built:** CLAUDE.md includes all of this.

### 5. AI Agents Hallucinate Nox APIs
Claude, Cursor, and other AI coding tools don't know Nox (too new, not in training data). Every AI-generated Nox code is wrong on the first attempt.

**What we built:** CLAUDE.md, AGENTS.md, and .cursorrules that fix this permanently for any project that includes them.

## Feature Requests

1. **CLAUDE.md / AGENTS.md from iExec** — An official AI-optimized knowledge file that the community can include in projects. We built a community version; an official one would be even better.
2. **`npx create-nox-app`** — Official scaffolder with working templates (we built a community version).
3. **Local testing mock** — Currently impossible to test without deploying to Arbitrum Sepolia. A local mock TEE would massively improve DX.
4. **Better error messages** — `ERC7984UnauthorizedUseOfEncryptedAmount` should suggest "Did you forget Nox.allowThis()?"
5. **React hooks package** — `useConfidentialBalance`, `useNoxEncrypt` would lower the frontend integration barrier.

## What We'd Love to See

The Nox MCP server on your roadmap is the right direction. Combined with community tools like nox-dev-kit, it could make Nox the easiest confidential computing platform to build on.

## Rating

**Core protocol: 9/10** — Nox itself is excellent. Gas-efficient, well-designed primitives, genuine differentiation vs FHE.

**Developer experience: 5/10** — Missing docs, no scaffolding, no examples, AI agents can't help. This is the #1 barrier to adoption.

**nox-dev-kit exists to close this gap.**
