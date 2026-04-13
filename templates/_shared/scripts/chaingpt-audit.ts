/**
 * ChainGPT Smart Contract Auditor
 * Sends your Nox contract to ChainGPT's auditor API for a professional security review.
 *
 * Usage: CHAINGPT_API_KEY=your_key npx tsx scripts/chaingpt-audit.ts contracts/YourContract.sol
 *
 * Get free API credits for the hackathon: contact @vladnazarxyz on Telegram
 * API docs: https://docs.chaingpt.org
 */
import fs from "fs";
import path from "path";

const API_URL = "https://api.chaingpt.org/chat/stream";

async function audit(contractPath: string) {
  const apiKey = process.env.CHAINGPT_API_KEY;
  if (!apiKey) {
    console.error("Error: CHAINGPT_API_KEY not set.");
    console.error("Get free credits at https://app.chaingpt.org or contact @vladnazarxyz on Telegram.");
    process.exit(1);
  }

  if (!fs.existsSync(contractPath)) {
    console.error(`File not found: ${contractPath}`);
    process.exit(1);
  }

  const source = fs.readFileSync(contractPath, "utf8");
  const fileName = path.basename(contractPath);

  console.log(`\n  ChainGPT Smart Contract Auditor`);
  console.log(`  Auditing: ${fileName}`);
  console.log(`  Powered by ChainGPT Web3 AI\n`);
  console.log(`  Sending to ChainGPT API...`);

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "smart_contract_auditor",
        question: `Audit this iExec Nox confidential smart contract for security vulnerabilities. It uses encrypted types (euint256, ebool) and the Nox TEE SDK (Nox.add, Nox.le, Nox.select, Nox.allow, Nox.allowThis, Nox.addViewer). Pay special attention to:
1. ACL misconfigurations (missing allow/allowThis)
2. Encrypted data leaks in events or view functions
3. Handle reuse vulnerabilities
4. Access control issues
5. Gas optimization opportunities

Contract source (${fileName}):

${source}`,
        chatHistory: "off",
      }),
    });

    const data = await response.json();
    const result = data?.data?.bot;

    if (result) {
      console.log(`\n  ── ChainGPT Audit Report ──\n`);
      console.log(result);
      console.log(`\n  ── End of Report ──\n`);

      // Save report
      const reportPath = `chaingpt-audit-${fileName.replace(".sol", "")}.md`;
      fs.writeFileSync(reportPath, `# ChainGPT Audit Report: ${fileName}\n\n${result}\n`);
      console.log(`  Report saved to: ${reportPath}`);
    } else {
      console.error("  No response from ChainGPT API.");
      console.error("  Response:", JSON.stringify(data).slice(0, 200));
    }
  } catch (err) {
    console.error("  API error:", (err as Error).message);
  }
}

const contractPath = process.argv[2];
if (!contractPath) {
  console.log("Usage: CHAINGPT_API_KEY=your_key npx tsx scripts/chaingpt-audit.ts contracts/YourContract.sol");
  process.exit(1);
}

audit(contractPath);
