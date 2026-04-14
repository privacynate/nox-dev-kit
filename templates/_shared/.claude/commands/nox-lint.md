Check the current Nox contract for common mistakes and auto-fix them

Review all Solidity files in contracts/ for these issues:
1. Missing Nox.allowThis() after every Nox operation (add, sub, le, select, toEuint256)
2. Missing Nox.allow() for addresses that need to read handles
3. Attempting to relay encrypted inputs through intermediary contracts
4. Using if/else on ebool instead of Nox.select()
5. Missing "type": "module" in package.json
6. Wrong Solidity version (must be ^0.8.28)
7. Stack-too-deep issues (suggest extracting to internal functions)
8. Missing access control on sensitive functions
Report each issue with line number, severity, and fix. Auto-fix what you can, then recompile.
