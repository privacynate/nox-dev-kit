#!/usr/bin/env node

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TEMPLATES_DIR = path.resolve(__dirname, "../templates");

const TEMPLATES = [
  { name: "hello-world", desc: "Confidential PiggyBank — Hello World for Nox", use: "Learn Nox basics", difficulty: "Beginner" },
  { name: "erc7984-wrapper", desc: "Wrap any ERC-20 into a confidential token (ERC-7984)", use: "Token privacy", difficulty: "Beginner" },
  { name: "confidential-escrow", desc: "Two parties deposit encrypted amounts, released on agreement", use: "P2P deals, M&A", difficulty: "Intermediate" },
  { name: "confidential-vesting", desc: "Token grants with encrypted amounts, cliff, and schedule", use: "Team tokens, KOL deals", difficulty: "Intermediate" },
  { name: "confidential-credit-line", desc: "Encrypted credit limit enforced by TEE, with auditor access", use: "Prime brokerage, DeFi lending", difficulty: "Advanced" },
];

function printBanner() {
  console.log(`
  ╔═══════════════════════════════════════════╗
  ║         nox-dev-kit v0.1.0                ║
  ║   Community starter kit for iExec Nox     ║
  ║   Confidential smart contracts made easy  ║
  ╚═══════════════════════════════════════════╝
  `);
}

function printUsage() {
  console.log("Usage: npx nox-dev-kit init [template] [project-name]\n");
  console.log("  What do you want to build?\n");
  TEMPLATES.forEach((t, i) => {
    console.log(`  ${(i + 1).toString().padStart(2)}. ${t.name}`);
    console.log(`      ${t.desc}`);
    console.log(`      Use case: ${t.use} | ${t.difficulty}\n`);
  });
  console.log("  Examples:");
  console.log("    npx nox-dev-kit init hello-world my-first-nox-app");
  console.log("    npx nox-dev-kit init confidential-vesting my-vesting-protocol");
  console.log("    npx nox-dev-kit init    (interactive mode)\n");
  console.log("  Each template includes:");
  console.log("    - CLAUDE.md (AI coding guide for Claude Code)");
  console.log("    - AGENTS.md (universal AI agent guide)");
  console.log("    - .cursorrules (Cursor IDE support)");
  console.log("    - 4 slash commands (/nox-scaffold, /nox-lint, /nox-deploy, /nox-audit)");
  console.log("    - Pre-configured Hardhat 3 + all Nox dependencies");
  console.log("    - ChainGPT auditor script\n");
}

function copyDirRecursive(src: string, dest: string) {
  if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });

  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

async function interactiveSelect(): Promise<string> {
  const readline = await import("readline");
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  return new Promise((resolve) => {
    console.log("\n  What do you want to build?\n");
    TEMPLATES.forEach((t, i) => {
      const num = `${i + 1}.`.padEnd(4);
      const badge = t.difficulty === "Beginner" ? "🟢" : t.difficulty === "Intermediate" ? "🟡" : "🔴";
      console.log(`  ${num}${badge} ${t.name}`);
      console.log(`      ${t.desc}`);
      console.log(`      → ${t.use}\n`);
    });
    rl.question("  Pick a template (1-5): ", (answer) => {
      rl.close();
      const idx = parseInt(answer) - 1;
      if (idx >= 0 && idx < TEMPLATES.length) {
        resolve(TEMPLATES[idx].name);
      } else {
        console.log("  Using hello-world (default).");
        resolve("hello-world");
      }
    });
  });
}

async function main() {
  printBanner();

  const args = process.argv.slice(2);
  const command = args[0];

  if (!command || command === "help" || command === "--help") {
    printUsage();
    process.exit(0);
  }

  if (command !== "init") {
    console.log(`Unknown command: ${command}`);
    printUsage();
    process.exit(1);
  }

  // Determine template
  let templateName = args[1];
  if (!templateName) {
    templateName = await interactiveSelect();
  }

  // Validate template
  const template = TEMPLATES.find((t) => t.name === templateName);
  if (!template) {
    console.log(`Unknown template: ${templateName}`);
    printUsage();
    process.exit(1);
  }

  // Determine project name
  const projectName = args[2] || `nox-${templateName}`;
  const projectDir = path.resolve(process.cwd(), projectName);

  if (fs.existsSync(projectDir)) {
    console.log(`Directory ${projectName} already exists!`);
    process.exit(1);
  }

  console.log(`Creating ${projectName} from template: ${template.name}...`);
  console.log(`  ${template.desc}\n`);

  // Copy shared files
  const sharedDir = path.join(TEMPLATES_DIR, "_shared");
  copyDirRecursive(sharedDir, projectDir);

  // Copy template-specific files
  const templateDir = path.join(TEMPLATES_DIR, templateName);
  copyDirRecursive(templateDir, projectDir);

  // Update package.json name
  const pkgPath = path.join(projectDir, "package.json");
  if (fs.existsSync(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
    pkg.name = projectName;
    fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2));
  }

  // Create .claude/commands directory for slash commands
  const commandsDir = path.join(projectDir, ".claude", "commands");
  fs.mkdirSync(commandsDir, { recursive: true });

  // Write slash commands
  fs.writeFileSync(
    path.join(commandsDir, "nox-scaffold.md"),
    `Generate a new Nox confidential smart contract based on my description. Use the patterns and rules from CLAUDE.md in this project. Always include proper Nox.allowThis() calls, ACL management, and follow the anti-patterns list. Use pragma solidity ^0.8.28 and the correct import paths.`
  );

  fs.writeFileSync(
    path.join(commandsDir, "nox-lint.md"),
    `Review the current Nox smart contract for common mistakes. Check for:
1. Missing Nox.allowThis() after every Nox operation (add, sub, le, select, toEuint256)
2. Missing Nox.allow() for addresses that need to read handles
3. Attempting to relay encrypted inputs through intermediary contracts
4. Using if/else on ebool instead of Nox.select()
5. Missing "type": "module" in package.json
6. Wrong Solidity version (must be ^0.8.28)
7. Stack-too-deep issues (suggest extracting to internal functions)
8. Missing access control on sensitive functions
Report each issue with line number and fix.`
  );

  fs.writeFileSync(
    path.join(commandsDir, "nox-deploy.md"),
    `Compile and deploy the current Nox contract to Arbitrum Sepolia. Steps:
1. Run: npx hardhat compile
2. Write a deployment script in scripts/deploy.ts using ethers v6
3. Run: npx tsx scripts/deploy.ts
4. Save the deployed address
5. Verify the contract is working by reading a public view function
Use the PRIVATE_KEY and ARBITRUM_SEPOLIA_RPC from .env file.`
  );

  fs.writeFileSync(
    path.join(commandsDir, "nox-audit.md"),
    `Run a security audit of the current Nox contract. Check for:
1. ACL misconfigurations — can unauthorized addresses decrypt sensitive handles?
2. Encrypted data leaks — are any encrypted values being emitted in events or returned from view functions without proper access control?
3. Re-entrancy risks in callback patterns (transferAndCall)
4. Missing input validation on externalEuint256 parameters
5. Proper use of safeAdd/safeSub for production (vs wrapping add/sub)
6. Time-based attack vectors (block.timestamp manipulation)
7. Centralization risks (single owner controlling ACL)
Provide a severity rating (Critical/High/Medium/Low/Info) for each finding.`
  );

  console.log("  Created project structure:");
  console.log(`  ${projectName}/`);
  console.log(`  ├── CLAUDE.md              ← Claude Code reads this automatically`);
  console.log(`  ├── AGENTS.md              ← Universal AI agent guide`);
  console.log(`  ├── .cursorrules           ← Cursor reads this automatically`);
  console.log(`  ├── .claude/commands/      ← Custom slash commands`);
  console.log(`  │   ├── nox-scaffold.md    ← /nox-scaffold`);
  console.log(`  │   ├── nox-lint.md        ← /nox-lint`);
  console.log(`  │   ├── nox-deploy.md      ← /nox-deploy`);
  console.log(`  │   └── nox-audit.md       ← /nox-audit`);
  console.log(`  ├── contracts/             ← Template contract(s)`);
  console.log(`  ├── hardhat.config.ts      ← Pre-configured for Nox + Arbitrum Sepolia`);
  console.log(`  ├── package.json           ← All Nox deps pre-installed`);
  console.log(`  ├── .env.example           ← Copy to .env and add your private key`);
  console.log(`  └── .gitignore`);
  console.log(`\n  Next steps:`);
  console.log(`  cd ${projectName}`);
  console.log(`  cp .env.example .env       # Add your private key`);
  console.log(`  pnpm install               # Install dependencies`);
  console.log(`  npx hardhat compile        # Compile contracts`);
  console.log(`\n  Then open in Claude Code / Cursor and start building!`);
  console.log(`  Use /nox-scaffold to generate new contracts.`);
  console.log(`  Use /nox-lint to check for common mistakes.`);
  console.log(`  Use /nox-deploy to deploy to Arbitrum Sepolia.\n`);
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
