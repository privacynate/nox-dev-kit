IMPORTANT: Display the following menu EXACTLY as written. Do NOT summarize, rephrase, or shorten it. Show every line:

---

**What would you like to build?**

**DeFi**
- **Confidential payroll** — batch encrypted salary transfers
- **Sealed-bid auction** — encrypted bids, reveal only the winner
- **Private lending pool** — encrypted deposits and positions
- **Dark pool swap** — encrypted order sizes, no front-running
- **Confidential lottery** — encrypted tickets, random winner

**TradFi on-chain**
- **Encrypted escrow** — bilateral deposit, released on agreement
- **Token vesting** — encrypted amounts with cliff and schedule
- **Credit line** — encrypted limit enforced by TEE
- **Letter of credit** — trade finance with encrypted terms

**Tokens & Compliance**
- **Confidential ERC-7984 token** — wrap any ERC-20 into confidential
- **Compliance-gated transfer** — encrypted spending limits
- **Private voting** — encrypted vote weights, public tally

**Data & Access**
- **Private NFT metadata** — encrypted attributes, selective reveal
- **Encrypted oracle** — confidential price feed
- **Access-controlled data store** — encrypted key-value store

Pick a number or describe what you want.

---

After the user chooses, generate a complete Solidity contract following ALL rules in CLAUDE.md. Include Nox.allowThis() after every operation, Nox.allow() for readers, Nox.addViewer() for auditors, events, NatSpec, and a deploy script.
