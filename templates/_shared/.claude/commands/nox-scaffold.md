Present the user with this menu of confidential smart contract templates. Show it exactly like this:

---

**What do you want to build?** Pick a use case:

| # | Use Case | Description | Nox Primitives |
|---|----------|-------------|----------------|
| 1 | **Confidential Payroll** | Batch-pay employees with encrypted salaries. Nobody sees what others earn. | fromExternal, allow, addViewer |
| 2 | **Sealed-Bid Auction** | Bidders submit encrypted bids. Winner found via Nox.le() without revealing losing bids. | le, select, add, allow |
| 3 | **Private Voting** | Encrypted vote weights. Tally computed on encrypted values. Result published, votes stay sealed. | add, allowThis, addViewer |
| 4 | **Confidential Escrow** | Two parties deposit encrypted amounts. Released on mutual agreement. Auditor gets viewer access. | fromExternal, allow, addViewer |
| 5 | **Token Vesting** | Encrypted grant amounts with cliff. Beneficiary claims over time. Nobody sees the schedule. | mul, div, sub, le, select |
| 6 | **Encrypted Credit Line** | Lender sets encrypted limit. Borrower draws down. TEE enforces limit without revealing it. | add, le, select, addViewer |
| 7 | **Compliance Check** | Protocol checks encrypted spending rules. Pass/fail result stored encrypted for audit. | le, select, allow, addViewer |
| 8 | **Confidential Lottery** | Players buy encrypted tickets. Winner selected via encrypted random comparison. | eq, select, allow |
| 9 | **Private Subscription** | Encrypted recurring payments with encrypted tier logic. | add, le, select, sub |
| 10 | **Custom** | Describe your own — I'll generate it using CLAUDE.md patterns. | Any |

Type a number (1-10) or describe what you want.

---

After the user picks, generate the complete Solidity contract following ALL rules from CLAUDE.md:
- Use pragma solidity ^0.8.28
- Import from @iexec-nox/nox-protocol-contracts/contracts/sdk/Nox.sol
- Call Nox.allowThis() after EVERY Nox operation
- Call Nox.allow() for every address that needs to read
- Use Nox.select() instead of if/else on ebool
- Use safeAdd/safeSub for production
- Include NatSpec documentation
- Include events for all state changes
- Include an auditor access function using Nox.addViewer()

Also generate a matching deploy script in scripts/deploy.ts.
