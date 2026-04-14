Deploy the current Nox contract to Arbitrum Sepolia

Steps:
1. Run: npx hardhat compile
2. Write a deployment script in scripts/deploy.ts using ethers v6
3. Run: npx tsx scripts/deploy.ts
4. Save the deployed address
5. Verify the contract is working by reading a public view function
Use the PRIVATE_KEY and ARBITRUM_SEPOLIA_RPC from .env file.
