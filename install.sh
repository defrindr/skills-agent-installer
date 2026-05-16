#!/bin/bash

# Skills Agent Installer
# Public installer for private repository: defrindr/skills-agent
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/defrindr/skills-agent-installer/main/install.sh)

set -e

REPO="defrindr/skills-agent"
INSTALL_DIR="$HOME/.skills-agent"
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║     Skills Agent Installer v1.0.0     ║"
echo "╚════════════════════════════════════════╝"
echo -e "${RESET}"

# Check Node.js
echo -e "${BLUE}Checking dependencies...${RESET}"
if ! command -v node >/dev/null 2>&1; then
  echo -e "${RED}❌ Node.js is required${RESET}"
  echo ""
  echo "Install Node.js from: https://nodejs.org"
  echo "Or use nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo -e "${RED}❌ npm is required${RESET}"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo -e "${RED}❌ git is required${RESET}"
  echo ""
  echo "Install git from: https://git-scm.com"
  exit 1
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
GIT_VERSION=$(git --version | head -1)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION}${RESET}"
echo -e "${GREEN}✓ npm ${NPM_VERSION}${RESET}"
echo -e "${GREEN}✓ ${GIT_VERSION}${RESET}"
echo ""

# Check GitHub authentication
echo -e "${BLUE}Checking GitHub authentication...${RESET}"

AUTH_METHOD=""

# Test SSH access
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  echo -e "${GREEN}✓ SSH key configured${RESET}"
  AUTH_METHOD="ssh"
  CLONE_URL="git@github.com:${REPO}.git"
else
  echo -e "${YELLOW}⚠ SSH key not configured, will use HTTPS${RESET}"
  AUTH_METHOD="https"
  CLONE_URL="https://github.com/${REPO}.git"
fi

echo -e "${BLUE}Using: ${AUTH_METHOD}${RESET}"
echo ""

# Show authentication instructions if needed
if [ "$AUTH_METHOD" = "https" ]; then
  echo -e "${YELLOW}Note: You'll be prompted for GitHub credentials${RESET}"
  echo ""
  echo "This repository is private. You need:"
  echo "  • GitHub username"
  echo "  • Personal Access Token (NOT password)"
  echo ""
  echo "To create a token:"
  echo "  1. Go to: https://github.com/settings/tokens"
  echo "  2. Generate new token (classic)"
  echo "  3. Select scope: 'repo' (full control)"
  echo "  4. Copy token and use as password"
  echo ""
  echo "Or setup SSH key (recommended):"
  echo "  1. ssh-keygen -t ed25519 -C \"your@email.com\""
  echo "  2. cat ~/.ssh/id_ed25519.pub"
  echo "  3. Add to: https://github.com/settings/keys"
  echo ""
  read -p "Press Enter to continue with HTTPS authentication..."
  echo ""
fi

# Remove old installation
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}⚠  Existing installation found${RESET}"
  echo "Location: $INSTALL_DIR"
  echo ""
  read -p "Remove old installation? (y/N): " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing old installation...${RESET}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓ Removed${RESET}"
    echo ""
  else
    echo -e "${RED}Installation cancelled${RESET}"
    exit 1
  fi
fi

# Clone repository
echo -e "${BLUE}Cloning repository...${RESET}"
echo "This may take a moment..."
echo ""

if git clone --depth 1 "$CLONE_URL" "$INSTALL_DIR" 2>&1; then
  echo -e "${GREEN}✓ Repository cloned${RESET}"
else
  EXIT_CODE=$?
  echo -e "${RED}❌ Clone failed${RESET}"
  echo ""
  
  if [ "$AUTH_METHOD" = "https" ]; then
    echo -e "${YELLOW}Authentication failed or access denied.${RESET}"
    echo ""
    echo "Possible issues:"
    echo "  • Using password instead of Personal Access Token"
    echo "  • Token doesn't have 'repo' scope"
    echo "  • No access to private repository"
    echo ""
    echo "Solutions:"
    echo "  1. Create Personal Access Token: https://github.com/settings/tokens"
    echo "  2. Use token as password (not your GitHub password)"
    echo "  3. Or setup SSH key (recommended)"
  else
    echo -e "${YELLOW}SSH authentication failed or access denied.${RESET}"
    echo ""
    echo "Possible issues:"
    echo "  • SSH key not added to GitHub"
    echo "  • No access to private repository"
    echo ""
    echo "Solutions:"
    echo "  1. Add SSH key: https://github.com/settings/keys"
    echo "  2. Test with: ssh -T git@github.com"
  fi
  
  exit $EXIT_CODE
fi
echo ""

# Navigate to package
cd "$INSTALL_DIR/skills-agent"

# Install dependencies
echo -e "${BLUE}Installing dependencies...${RESET}"
echo "This may take a minute..."
echo ""

if npm install --silent 2>&1 | grep -E "(added|removed|changed|audited)" || true; then
  echo ""
  echo -e "${GREEN}✓ Dependencies installed${RESET}"
else
  echo -e "${RED}❌ npm install failed${RESET}"
  exit 1
fi
echo ""

# Build
echo -e "${BLUE}Building...${RESET}"
if npm run build --silent 2>&1; then
  echo -e "${GREEN}✓ Build complete${RESET}"
else
  echo -e "${RED}❌ Build failed${RESET}"
  exit 1
fi
echo ""

# Run setup
echo -e "${BLUE}Running setup...${RESET}"
echo ""

if node dist/setup.js; then
  echo ""
  echo -e "${GREEN}✓ Setup complete${RESET}"
else
  echo -e "${RED}❌ Setup failed${RESET}"
  exit 1
fi
echo ""

# Success message
echo -e "${GREEN}${BOLD}"
echo "╔════════════════════════════════════════╗"
echo "║    Installation Complete! 🎉          ║"
echo "╚════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""

echo -e "${BOLD}What was installed:${RESET}"
echo "  ✓ MCP Server: ~/.skills-agent/skills-agent/"
echo "  ✓ 21 Skills: ~/.agents/skills/"
echo "    - 8 common (codebase-explorer, code-health, etc.)"
echo "    - 5 backend (expressjs, fastapi, golang, laravel, nestjs)"
echo "    - 6 frontend (nextjs, react, tailwind, vue, etc.)"
echo "    - 2 mobile (flutter, react-native)"
echo "  ✓ OpenCode MCP: ~/.config/opencode/opencode.json"
echo ""

echo -e "${BOLD}Next steps:${RESET}"
echo ""
echo -e "  1. ${BOLD}Restart OpenCode${RESET}"
echo "     Quit completely (Cmd+Q) and reopen"
echo ""
echo -e "  2. ${BOLD}Verify installation${RESET}"
echo -e "     Run in terminal: ${BLUE}opencode mcp list${RESET}"
echo "     Should show: ✓ skills-agent connected"
echo ""
echo -e "  3. ${BOLD}Start using skills!${RESET}"
echo "     In OpenCode, ask:"
echo "     - \"Initialize new project\" (auto-loads project-initializer)"
echo "     - \"Check code health\" (auto-loads code-health)"
echo "     - \"Explore codebase\" (auto-loads codebase-explorer)"
echo ""

echo -e "${BOLD}Documentation:${RESET}"
echo -e "  ${BLUE}$INSTALL_DIR/skills-agent/MCP-OPENCODE.md${RESET}"
echo ""

echo -e "${BOLD}To uninstall:${RESET}"
echo -e "  ${BLUE}bash ~/.skills-agent/skills-agent/uninstall.sh${RESET}"
echo ""

echo -e "${BOLD}GitHub:${RESET}"
echo -e "  ${BLUE}https://github.com/$REPO${RESET}"
echo ""

echo -e "${GREEN}Happy coding! 🚀${RESET}"
