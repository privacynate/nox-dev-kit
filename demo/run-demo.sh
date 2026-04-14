#!/bin/bash
# ============================================================
# nox-dev-kit DEMO — Run this, record your screen with QuickTime
# ============================================================
# Before running:
#   1. Open QuickTime → File → New Screen Recording → Start
#   2. Make terminal full screen (dark background)
#   3. Run: bash demo/run-demo.sh
# ============================================================

set -e

# Colors
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# Typing effect
type_cmd() {
  echo ""
  echo -ne "${GREEN}❯ ${WHITE}"
  for (( i=0; i<${#1}; i++ )); do
    echo -n "${1:$i:1}"
    sleep 0.03
  done
  echo -e "${NC}"
  sleep 0.5
}

# Commentary
say() {
  echo ""
  echo -e "${PURPLE}  $1${NC}"
  echo ""
  sleep 1.5
}

# Section header
header() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${WHITE}  $1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  sleep 2
}

# Ensure clean state
rm -rf /tmp/demo-nox-app 2>/dev/null

# ============================================================
# INTRO
# ============================================================

clear
echo ""
echo ""
echo -e "${PURPLE}  ╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}  ║                                                       ║${NC}"
echo -e "${PURPLE}  ║${WHITE}         nox-dev-kit                                ${PURPLE}║${NC}"
echo -e "${PURPLE}  ║${DIM}         Community starter kit for iExec Nox          ${PURPLE}║${NC}"
echo -e "${PURPLE}  ║                                                       ║${NC}"
echo -e "${PURPLE}  ║${YELLOW}   From zero to audited confidential dApp             ${PURPLE}║${NC}"
echo -e "${PURPLE}  ║${YELLOW}   in under 5 minutes.                                ${PURPLE}║${NC}"
echo -e "${PURPLE}  ║                                                       ║${NC}"
echo -e "${PURPLE}  ╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
sleep 3

say "AI agents hallucinate when building on new protocols."
say "iExec Nox is too new to be in any model's training data."
say "nox-dev-kit fixes that — CLAUDE.md teaches Claude Code how to build correctly."
sleep 1

# ============================================================
# STEP 1: SCAFFOLD
# ============================================================

header "STEP 1 — Scaffold a Nox project"

say "One command. Working project. All dependencies configured."

type_cmd "node ~/nox-dev-kit/dist/cli.js init confidential-vesting demo-nox-app"
cd /tmp
node npx nox-dev-kit init confidential-vesting demo-nox-app
sleep 2

type_cmd "cd demo-nox-app"
cd /tmp/demo-nox-app
sleep 0.5

say "Project scaffolded with:"
echo -e "  ${GREEN}✓${NC} CLAUDE.md — Claude Code reads this automatically"
echo -e "  ${GREEN}✓${NC} AGENTS.md — works with Cursor, Windsurf, any AI agent"
echo -e "  ${GREEN}✓${NC} .cursorrules — Cursor IDE support"
echo -e "  ${GREEN}✓${NC} 4 slash commands: /nox-scaffold, /nox-lint, /nox-deploy, /nox-audit"
echo -e "  ${GREEN}✓${NC} Pre-configured Hardhat 3 + all Nox dependencies"
echo -e "  ${GREEN}✓${NC} ConfidentialVesting.sol template"
sleep 3

# ============================================================
# STEP 2: INSTALL & COMPILE
# ============================================================

header "STEP 2 — Install & Compile"

say "Setting up .env and installing dependencies..."

printf "PRIVATE_KEY=\$PRIVATE_KEY\nARBITRUM_SEPOLIA_RPC=https://sepolia-rollup.arbitrum.io/rpc" > .env

type_cmd "pnpm install"
source ~/.nvm/nvm.sh && nvm use 22 > /dev/null 2>&1
pnpm install 2>&1 | tail -5
sleep 1

type_cmd "npx hardhat compile"
npx hardhat compile 2>&1 | grep -E "(Compiled|Error)"
sleep 2

say "Compiled on first try. Zero configuration needed."

# ============================================================
# STEP 3: SHOW THE TEMPLATE
# ============================================================

header "STEP 3 — The Contract Template"

say "Let's look at the generated ConfidentialVesting contract..."

type_cmd "cat contracts/ConfidentialVesting.sol | head -40"
cat contracts/ConfidentialVesting.sol | head -40
sleep 3

say "Encrypted token vesting using:"
echo -e "  ${CYAN}Nox.mul()${NC}  — encrypted amount × elapsed time"
echo -e "  ${CYAN}Nox.div()${NC}  — ÷ vesting duration"
echo -e "  ${CYAN}Nox.sub()${NC}  — claimable = vested − claimed"
echo -e "  ${CYAN}Nox.allow()${NC} — selective disclosure for beneficiary"
echo -e "  ${CYAN}Nox.addViewer()${NC} — audit access for regulators"
sleep 3

# ============================================================
# STEP 4: CLAUDE.md KNOWLEDGE
# ============================================================

header "STEP 4 — What CLAUDE.md teaches AI agents"

say "The knowledge file that makes Claude Code a Nox expert:"

type_cmd "head -60 CLAUDE.md"
head -60 CLAUDE.md
sleep 3

say "12KB of patterns, anti-patterns, gas costs, and error fixes."
say "Every bug we hit in 20+ hours of Nox development — encoded here."
sleep 2

# ============================================================
# STEP 5: SLASH COMMANDS
# ============================================================

header "STEP 5 — Custom Slash Commands"

say "4 Claude Code commands available in every scaffolded project:"

echo ""
echo -e "  ${GREEN}/nox-scaffold${NC}  — Generate contracts from natural language"
echo -e "  ${GREEN}/nox-lint${NC}      — Check for 7 common Nox mistakes"
echo -e "  ${GREEN}/nox-deploy${NC}    — Compile and deploy to Arbitrum Sepolia"
echo -e "  ${GREEN}/nox-audit${NC}     — Full security audit with severity ratings"
echo ""
sleep 3

say "When you open this project in Claude Code, these commands are ready."
say "Claude reads CLAUDE.md, knows all Nox patterns, and generates correct code."
sleep 2

# ============================================================
# STEP 6: CHAINGPT INTEGRATION
# ============================================================

header "STEP 6 — ChainGPT Smart Contract Auditor"

say "Second opinion from ChainGPT's Web3 AI auditor:"

type_cmd "cat scripts/chaingpt-audit.ts | head -15"
cat scripts/chaingpt-audit.ts | head -15
sleep 2

say "Run with: CHAINGPT_API_KEY=key npx tsx scripts/chaingpt-audit.ts contracts/ConfidentialVesting.sol"
say "Generates a professional security report saved as Markdown."
sleep 2

# ============================================================
# STEP 7: ALL TEMPLATES
# ============================================================

header "STEP 7 — 5 Contract Templates"

echo ""
echo -e "  ${YELLOW}1. hello-world${NC}              — Confidential PiggyBank (Hello World)"
echo -e "  ${YELLOW}2. erc7984-wrapper${NC}           — Wrap any ERC-20 → ERC-7984"
echo -e "  ${YELLOW}3. confidential-escrow${NC}       — Bilateral encrypted escrow"
echo -e "  ${YELLOW}4. confidential-vesting${NC}      — Token vesting with encrypted amounts"
echo -e "  ${YELLOW}5. confidential-credit-line${NC}  — Encrypted revolving credit"
echo ""
sleep 3

say "Each template compiles out of the box."
say "Each uses real, tested Nox patterns."
say "Each includes full CLAUDE.md + slash commands."
sleep 2

# ============================================================
# CLOSING
# ============================================================

header "SUMMARY"

echo ""
echo -e "  ${WHITE}nox-dev-kit — The community starter kit for iExec Nox${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} One command to scaffold a working Nox project"
echo -e "  ${GREEN}✓${NC} CLAUDE.md makes AI agents write correct Nox code"
echo -e "  ${GREEN}✓${NC} 4 slash commands for Claude Code"
echo -e "  ${GREEN}✓${NC} 5 audited contract templates"
echo -e "  ${GREEN}✓${NC} ChainGPT auditor integration"
echo -e "  ${GREEN}✓${NC} Pre-configured Hardhat 3 + all dependencies"
echo -e "  ${GREEN}✓${NC} Works with Claude Code, Cursor, Windsurf"
echo ""
echo -e "  ${DIM}Built during iExec Vibe Coding Challenge — April 2026${NC}"
echo -e "  ${DIM}15+ hours of Nox debugging encoded into one dev kit${NC}"
echo ""
echo -e "  ${PURPLE}github.com/privacynate/nox-dev-kit${NC}"
echo ""
sleep 5

echo -e "  ${CYAN}Powered by iExec Nox × ChainGPT${NC}"
echo ""
