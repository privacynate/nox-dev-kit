# nox-dev-kit

**Community starter kit for building confidential dApps on iExec Nox.**

One command. AI-ready. Compiles out of the box.

```bash
npx nox-dev-kit init hello-world my-first-nox-app
cd my-first-nox-app
pnpm install
npx hardhat compile
# Done. Open in Claude Code / Cursor and start building.
```

## What's Inside

Every scaffolded project includes:

| File | Purpose | Used By |
|------|---------|---------|
| `CLAUDE.md` | Comprehensive Nox coding guide — primitives, patterns, anti-patterns, gas costs | Claude Code (auto-loaded) |
| `AGENTS.md` | Universal AI agent guide with decision tree and quick rules | Any AI agent |
| `.cursorrules` | Nox coding rules for Cursor IDE | Cursor (auto-loaded) |
| `.claude/commands/` | Custom slash commands for Claude Code | Claude Code |
| `contracts/` | Working template contract(s) | Developer |
| `hardhat.config.ts` | Pre-configured for Hardhat 3 + Nox + Arbitrum Sepolia | Hardhat |
| `package.json` | All Nox dependencies with version overrides | pnpm/npm |

## Templates

```bash
npx nox-dev-kit init [template] [project-name]
```

| Template | Description | Nox Primitives Used |
|----------|-------------|---------------------|
| `hello-world` | Confidential PiggyBank | toEuint256, fromExternal, add, sub, allow |
| `erc7984-wrapper` | Wrap ERC-20 → ERC-7984 | ERC7984, ERC20ToERC7984Wrapper |
| `confidential-escrow` | Bilateral encrypted escrow | fromExternal, allow, addViewer, multi-party ACL |
| `confidential-vesting` | Token vesting with encrypted amounts | mul, div, le, select, sub, time-based logic |
| `confidential-credit-line` | Encrypted revolving credit (prime brokerage) | add, le, select, safeAdd, addViewer |

## Slash Commands (Claude Code)

After scaffolding, these commands are available in Claude Code:

| Command | What It Does |
|---------|-------------|
| `/nox-scaffold` | Generate a new Nox contract from a natural language description |
| `/nox-lint` | Check your contract for 7 common Nox mistakes |
| `/nox-deploy` | Compile and deploy to Arbitrum Sepolia |
| `/nox-audit` | Run a security audit focused on encrypted data and ACL |

## Why This Exists

We spent a week building [NoxTreasury](https://github.com/privacynate/nox-treasury) on iExec Nox. Every bug we hit, every workaround we found, every pattern we discovered — it's all encoded in the `CLAUDE.md` and templates.

**The pain we're solving:**

| Problem | Hours Lost | Fix In nox-dev-kit |
|---------|-----------|-------------------|
| Missing `allowThis` after Nox ops | 2h | CLAUDE.md Rule #1 + `/nox-lint` detects it |
| Version mismatch (beta.7 vs beta.9) | 3h | package.json has pnpm overrides |
| Hardhat 3 config not documented | 1h | Pre-configured hardhat.config.ts |
| Encrypted inputs bound to wrong contract | 2h | CLAUDE.md Rule #3 explains with examples |
| Gas estimation failures on Arbitrum | 2h | CLAUDE.md has the EIP-1559 fix |
| No local testing possible | Ongoing | Templates are pre-tested, compile on first try |
| AI agents hallucinate Nox APIs | Every session | CLAUDE.md + AGENTS.md fix this permanently |

**Total developer hours saved: 15+ per project.**

## The CLAUDE.md Difference

Without `CLAUDE.md`, Claude Code writes this:

```solidity
// WRONG — Claude hallucinates the API
import { NoxEncrypted } from "nox-sdk"; // doesn't exist
uint256 encrypted = NoxEncrypted.encrypt(100); // not how it works
```

With `CLAUDE.md`, Claude Code writes this:

```solidity
// CORRECT — real Nox API
import {Nox, euint256, externalEuint256} from "@iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol";
euint256 amount = Nox.fromExternal(encryptedAmount, inputProof);
Nox.allowThis(amount); // ← Claude knows to do this because of CLAUDE.md
```

## How It Complements iExec's Roadmap

iExec is building an AI MCP server for Nox (runtime infra). `nox-dev-kit` is the **knowledge layer** that works with or without MCP:

- MCP not available yet → `CLAUDE.md` + slash commands handle everything
- MCP ships → our templates and knowledge base plug right into it
- Developers get value TODAY, not when MCP is production-ready

## Requirements

- Node.js ≥ 22
- pnpm ≥ 10
- MetaMask or wallet on Arbitrum Sepolia
- Arbitrum Sepolia ETH for gas

## Built During

[iExec Vibe Coding Challenge](https://dorahacks.io/hackathon/vibe-coding-iexec) — April 2026

Built with Claude Code. Tested with real deployments on Arbitrum Sepolia.

## License

MIT — fork, extend, contribute.
