Generate a new Nox confidential smart contract. First, present this menu exactly as shown:

**What would you like to build?** Pick a category and use case:

**DeFi**
- **Confidential payroll** — batch encrypted salary transfers
- **Sealed-bid auction** — encrypted bids, reveal only the winner
- **Private lending pool** — encrypted deposits and positions
- **Dark pool swap** — encrypted order sizes, no front-running
- **Confidential lottery** — encrypted tickets, random winner selection

**TradFi on-chain**
- **Encrypted escrow** — bilateral deposit, released on mutual agreement
- **Token vesting** — encrypted amounts with cliff and schedule
- **Credit line** — encrypted limit enforced by TEE
- **Letter of credit** — trade finance with encrypted terms

**Tokens & Compliance**
- **Confidential ERC-7984 token wrapper** — wrap any ERC-20 into a confidential token
- **Compliance-gated transfer** — encrypted amount vs encrypted spending limit
- **Private voting** — encrypted vote weights, public tally

**Data & Access**
- **Private NFT metadata** — encrypted attributes, selective reveal
- **Encrypted oracle** — confidential price feed for DeFi protocols
- **Access-controlled data store** — encrypted key-value with selective disclosure

Give me a short description (purpose, actors, key operations) and I'll scaffold the contract following the CLAUDE.md rules.

---

After the user picks, generate the complete Solidity contract following ALL rules from CLAUDE.md:
- pragma solidity ^0.8.28
- Import from @iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol
- Nox.allowThis() after EVERY Nox operation
- Nox.allow() for every address that needs to read
- Nox.select() instead of if/else on ebool
- safeAdd/safeSub for production
- NatSpec documentation
- Events for all state changes
- An auditor access function using Nox.addViewer()
- A matching deploy script in scripts/deploy.ts
