# iExec Nox Protocol — AI Coding Guide

You are building confidential smart contracts using iExec Nox on Arbitrum Sepolia. This guide contains CRITICAL rules, patterns, and anti-patterns learned from real development. Follow them strictly.

## What is Nox

Nox is a confidential computing layer that lets Solidity contracts compute on encrypted data using Trusted Execution Environments (TEE). Values are stored as encrypted handles (`euint256`) on-chain. The actual encrypted data lives off-chain in the Handle Gateway. Computation happens in Intel SGX enclaves via the Runner.

**Key insight:** Nox provides AUDITABLE PRIVACY, not anonymity. Data is encrypted by default, but authorized parties can decrypt via selective disclosure (`addViewer`).

## Critical Import

```solidity
import {Nox, euint256, externalEuint256, ebool} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";
```

Always use this EXACT import path. Do NOT guess alternate paths.

## Required Solidity Version

```solidity
pragma solidity ^0.8.28;
```

Nox SDK requires ^0.8.27 minimum. Use 0.8.28.

## CRITICAL RULES — MUST FOLLOW

### Rule 1: ALWAYS call `Nox.allowThis()` after EVERY Nox operation

Every Nox computation (add, sub, le, select, toEuint256) creates a NEW handle. The contract does NOT automatically have access to use this handle. You MUST call `allowThis` immediately.

```solidity
// WRONG — will revert with UnauthorizedUseOfEncryptedAmount
euint256 result = Nox.add(a, b);
balance = result; // FAILS

// CORRECT
euint256 result = Nox.add(a, b);
Nox.allowThis(result);  // ← ALWAYS DO THIS
balance = result;
```

### Rule 2: ALWAYS call `Nox.allow()` for external readers

If any address (user, auditor, other contract) needs to decrypt or use a handle, grant access explicitly.

```solidity
Nox.allow(result, msg.sender);     // User can decrypt their own data
Nox.allow(result, owner);          // Owner can see it
Nox.addViewer(result, auditor);    // Auditor gets decrypt-only access
```

### Rule 3: Encrypted inputs are BOUND to a specific contract address

When a user encrypts a value via the Handle SDK, the proof is bound to the target contract's address. `Nox.fromExternal()` validates this. You CANNOT relay encrypted inputs through intermediary contracts.

```solidity
// This works — user encrypted for THIS contract
euint256 amount = Nox.fromExternal(encryptedAmount, inputProof);

// This FAILS — trying to pass the input to ANOTHER contract
// The other contract's fromExternal will reject it because msg.sender changed
OtherContract(addr).doSomething(encryptedAmount, inputProof); // REVERTS
```

**Solution:** If you need two contracts to process the same value, the user must encrypt TWICE — once per target contract.

### Rule 4: Use `safeAdd/safeSub` for production

`Nox.add()` and `Nox.sub()` use wrapping arithmetic (overflow wraps). For production code, use safe variants that return a success boolean:

```solidity
(ebool ok, euint256 result) = Nox.safeAdd(a, b);
euint256 finalValue = Nox.select(ok, result, a); // Keep original if overflow
Nox.allowThis(finalValue);
```

### Rule 5: `Nox.select()` is your if/else for encrypted values

You cannot use regular Solidity `if` statements on encrypted booleans. Use `Nox.select()`:

```solidity
ebool isEnough = Nox.le(amount, limit);
// WRONG: if (isEnough) { ... } — ebool is NOT a regular bool
// CORRECT:
euint256 result = Nox.select(isEnough, amount, Nox.toEuint256(0));
Nox.allowThis(result);
```

## All Nox Primitives

### Plaintext to Encrypted
| Function | Gas | Description |
|----------|-----|-------------|
| `Nox.toEuint256(uint256)` | ~33K | Convert plaintext to encrypted |
| `Nox.toEbool(bool)` | ~33K | Convert plaintext bool to encrypted |

### Arithmetic (wrapping)
| Function | Gas | Description |
|----------|-----|-------------|
| `Nox.add(euint256, euint256)` | ~44K | Encrypted addition |
| `Nox.sub(euint256, euint256)` | ~44K | Encrypted subtraction |
| `Nox.mul(euint256, euint256)` | ~44K | Encrypted multiplication |
| `Nox.div(euint256, euint256)` | ~44K | Encrypted division |

### Safe Arithmetic (returns ebool success + result)
| Function | Gas | Description |
|----------|-----|-------------|
| `Nox.safeAdd(a, b)` | ~46K | Returns `(ebool ok, euint256 result)` |
| `Nox.safeSub(a, b)` | ~46K | Returns `(ebool ok, euint256 result)` |
| `Nox.safeMul(a, b)` | ~46K | Returns `(ebool ok, euint256 result)` |
| `Nox.safeDiv(a, b)` | ~46K | Returns `(ebool ok, euint256 result)` |

### Comparisons (return ebool)
| Function | Gas | Description |
|----------|-----|-------------|
| `Nox.eq(a, b)` | ~44K | Equal |
| `Nox.ne(a, b)` | ~44K | Not equal |
| `Nox.lt(a, b)` | ~44K | Less than |
| `Nox.le(a, b)` | ~44K | Less than or equal |
| `Nox.gt(a, b)` | ~44K | Greater than |
| `Nox.ge(a, b)` | ~44K | Greater than or equal |

### Conditional
| Function | Gas | Description |
|----------|-----|-------------|
| `Nox.select(ebool, euint256 ifTrue, euint256 ifFalse)` | ~47K | Ternary on encrypted bool |

### Access Control
| Function | Description |
|----------|-------------|
| `Nox.allow(handle, address)` | Persistent admin access |
| `Nox.allowThis(handle)` | Let this contract reuse the handle |
| `Nox.allowTransient(handle, address)` | Single-transaction access |
| `Nox.addViewer(handle, address)` | Decrypt-only access (for auditors) |
| `Nox.allowPublicDecryption(handle)` | Anyone can decrypt |
| `Nox.isAllowed(handle, address)` | Check if allowed |
| `Nox.isInitialized(handle)` | Check if handle exists |

### External Input
| Function | Description |
|----------|-------------|
| `Nox.fromExternal(externalEuint256, bytes proof)` | Validate and import user-encrypted input |

## ERC-7984 Confidential Token

The confidential fungible token standard. Key differences from ERC-20:

| ERC-20 | ERC-7984 |
|--------|----------|
| `balanceOf → uint256` | `confidentialBalanceOf → euint256` (encrypted handle) |
| `transfer(to, amount)` | `confidentialTransfer(to, encryptedAmount, proof)` |
| `approve(spender, amount)` | `setOperator(operator, uint48 until)` (time-bound, no amount) |
| `transferFrom(from, to, amount)` | `confidentialTransferFrom(from, to, encryptedAmount, proof)` |

### Wrapping ERC-20 → ERC-7984
```solidity
import {ERC20ToERC7984Wrapper} from "@iexec-nox/nox-confidential-contracts/contracts/token/extensions/ERC20ToERC7984Wrapper.sol";

contract MyConfidentialToken is ERC20ToERC7984Wrapper {
    constructor(address underlying_)
        ERC20ToERC7984Wrapper(IERC20(underlying_))
        ERC7984("Confidential Token", "cTOKEN", "") {}
}
```

### Wrap flow
```
approve(wrapperAddress, amount) → wrapper.wrap(to, amount) → cToken minted
```

### Unwrap flow (2-step async)
```
wrapper.unwrap(from, to, amount) → finalizeUnwrap(requestId, proof) → ERC-20 released
```

## JavaScript/TypeScript SDK

### Handle Client (encryption/decryption)

```typescript
import { createEthersHandleClient } from '@iexec-nox/handle';
import { BrowserProvider } from 'ethers';

// Browser
const provider = new BrowserProvider(window.ethereum);
const handleClient = await createEthersHandleClient(provider);

// Node.js
import { JsonRpcProvider, Wallet } from 'ethers';
const provider = new JsonRpcProvider(RPC_URL);
const signer = new Wallet(PRIVATE_KEY, provider);
const handleClient = await createEthersHandleClient(signer);

// Encrypt
const { handle, handleProof } = await handleClient.encryptInput(
  100000000n,       // value (bigint)
  'uint256',        // solidity type
  contractAddress   // TARGET contract (proof is bound to this address!)
);

// Decrypt (requires viewer/admin access)
const { value } = await handleClient.decrypt(handleHex);
```

## Hardhat 3 Configuration

```typescript
// hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ignition";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: { version: "0.8.28", settings: { optimizer: { enabled: true, runs: 200 } } },
  networks: {
    arbitrumSepolia: {
      type: "http",  // ← REQUIRED for Hardhat 3
      url: process.env.ARBITRUM_SEPOLIA_RPC || "https://sepolia-rollup.arbitrum.io/rpc",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 421614,
    },
  },
};
export default config;
```

**Requirements:**
- Node.js ≥ 22 (Node 20 fails with Hardhat 3)
- pnpm ≥ 10
- `"type": "module"` in package.json (Hardhat 3 is ESM-only)

## Package Version Compatibility

**CRITICAL:** All `@iexec-nox` packages must use the SAME version of `nox-protocol-contracts`. If `nox-confidential-contracts` depends on beta.7 but you installed beta.9, handles will have incompatible formats.

Fix with pnpm overrides:
```json
{
  "pnpm": {
    "overrides": {
      "@iexec-nox/nox-protocol-contracts": "0.1.0-beta.9"
    }
  }
}
```

## Common Errors and Fixes

### `ERC7984UnauthorizedUseOfEncryptedAmount`
**Cause:** Missing `Nox.allowThis()` or `Nox.allow()` on a handle before using it.
**Fix:** Add `Nox.allowThis(handle)` after every Nox operation.

### `Handle chainId does not match connected chainId`
**Cause:** Package version mismatch. Different beta versions encode handle format differently.
**Fix:** Force all packages to same beta version via pnpm overrides.

### `max fee per gas less than block base fee` (Arbitrum Sepolia)
**Cause:** MetaMask underestimates gas on Arbitrum.
**Fix:** Set explicit EIP-1559 params: `maxFeePerGas = baseFee * 10`, `maxPriorityFeePerGas = baseFee`.

### `Stack too deep` in Solidity
**Cause:** Too many local variables in one function (common with multiple Nox ops).
**Fix:** Extract logic into internal helper functions.

### Encrypted input rejected by another contract
**Cause:** Input proof is bound to the encrypting contract address. Can't relay through intermediaries.
**Fix:** User must encrypt separately per target contract.

## Architecture Patterns

### Pattern 1: Direct Encrypted Transfer
User → cToken.confidentialTransfer(to, encryptedAmount, proof)
Simple. No intermediary. Use for payroll, OTC.

### Pattern 2: Policy-Checked Transfer
User → ComplianceContract.check(rulesetId, encryptedAmount, proof) → result stored
User → cToken.confidentialTransfer (separate tx)
Compliance is advisory, not atomic. Check result can be verified by auditors.

### Pattern 3: Callback-Based (transferAndCall)
User → cToken.confidentialTransferAndCall(receiver, encryptedAmount, proof, data)
Receiver contract gets callback with the transferred handle.
Can implement refund logic (return encrypted false to refund).

### Pattern 4: Selective Disclosure (Audit Trail)
Every sensitive operation → store encrypted result via Nox.allow(result, owner)
Grant auditors: Nox.addViewer(result, auditorAddress)
Auditors decrypt via Handle SDK to verify compliance.

## Gas Costs Reference (Nox vs Zama fhEVM)

| Operation | Nox Gas | Zama Gas | Savings |
|-----------|---------|----------|---------|
| add | 44,749 | 68,649 | 35% |
| le (comparison) | 44,157 | 68,625 | 36% |
| select (ternary) | 47,134 | 74,760 | 37% |
| safeAdd | 46,414 | 106,220 | 56% |
| transfer | 50,913 | 335,443 | 85% |
| mint | 50,694 | 305,789 | 83% |

## Deployed Contract Addresses (Arbitrum Sepolia)

| Contract | Address |
|----------|---------|
| NoxCompute Proxy | Check @iexec-nox/nox-protocol-contracts SDK constants |
| Handle Gateway | Auto-detected by @iexec-nox/handle SDK |

## Frontend Integration (wagmi + viem)

```typescript
import { createConfig, http } from "wagmi";
import { arbitrumSepolia } from "wagmi/chains";
import { injected } from "wagmi/connectors";

export const config = createConfig({
  chains: [arbitrumSepolia],
  connectors: [injected()],
  transports: { [arbitrumSepolia.id]: http("https://sepolia-rollup.arbitrum.io/rpc") },
});
```

Use `useWriteContract` from wagmi for all contract calls. For gas on Arbitrum Sepolia, fetch the block's `baseFeePerGas` and set `maxFeePerGas` to 10x with `maxPriorityFeePerGas` equal to baseFee.
