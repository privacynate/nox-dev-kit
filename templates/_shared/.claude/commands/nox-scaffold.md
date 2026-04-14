Generate a new Nox confidential smart contract. First, present this menu:

**What kind of confidential smart contract would you like to generate?** For example:

- **Confidential token** (ERC-7984 wrapper around an ERC-20)
- **Private vault** (deposit/withdraw with encrypted balances)
- **Confidential voting** (encrypted votes with tallying)
- **Private payroll** (batch encrypted salary payments)
- **Confidential auction** (sealed-bid auction with encrypted bids)
- **Access-controlled data store** (encrypted key-value with selective disclosure)
- **Encrypted escrow** (bilateral deposit with auditor access)
- **Token vesting** (encrypted amounts with cliff and schedule)
- **Credit line** (encrypted limit enforced by TEE)
- **Compliance check** (encrypted spending rules, pass/fail result)

Describe what you want to build and I'll scaffold the contract with proper Nox patterns.

After the user picks, generate the complete Solidity contract following ALL rules from CLAUDE.md. Always include:
- pragma solidity ^0.8.28
- Correct import from @iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol
- Nox.allowThis() after EVERY Nox operation
- Nox.allow() for every address that needs to read
- Nox.select() instead of if/else on ebool
- NatSpec documentation
- Events for state changes
- An auditor access function using Nox.addViewer()
- A matching deploy script in scripts/deploy.ts
