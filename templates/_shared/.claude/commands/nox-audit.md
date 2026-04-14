Run a full security audit of the current Nox contract

Check for:
1. ACL misconfigurations — can unauthorized addresses decrypt sensitive handles?
2. Encrypted data leaks — are any encrypted values being emitted in events or returned from view functions without proper access control?
3. Re-entrancy risks in callback patterns (transferAndCall)
4. Missing input validation on externalEuint256 parameters
5. Proper use of safeAdd/safeSub for production (vs wrapping add/sub)
6. Time-based attack vectors (block.timestamp manipulation)
7. Centralization risks (single owner controlling ACL)
Provide a severity rating (Critical/High/Medium/Low/Info) for each finding. Auto-fix what you can.
