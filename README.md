# Skills Agent Installer

**Public installer for private Skills Agent MCP server repository.**

One-command installation for OpenCode AI agent skills.

---

## Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/defrindr/skills-agent-installer/main/install.sh)
```

---

## Prerequisites

### 1. Node.js 18+

**macOS:**
```bash
brew install node
```

**Linux:**
```bash
# Debian/Ubuntu
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Fedora
sudo dnf install nodejs
```

**Or use nvm (recommended):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
```

### 2. Git

**macOS:**
```bash
brew install git
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install git

# Fedora
sudo dnf install git
```

### 3. GitHub Authentication

**Option A: SSH Key (Recommended)**

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys

# Test connection
ssh -T git@github.com
```

**Option B: Personal Access Token (HTTPS)**

1. Create token: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scope: **repo** (full control)
4. Copy token
5. Use token as password when prompted during install

---

## Installation

Run the installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/defrindr/skills-agent-installer/main/install.sh)
```

The installer will:
1. Check dependencies (Node.js, npm, git)
2. Detect authentication method (SSH or HTTPS)
3. Clone private repository
4. Build and setup components
5. Configure OpenCode integration

---

## Verification

### 1. Restart OpenCode

Quit completely (Cmd+Q / Ctrl+Q) and reopen.

### 2. Check MCP Connection

```bash
opencode mcp list
```

Should show the MCP server connected.

### 3. Check Installation

```bash
ls -la ~/.skills-agent/
```

Should show the installation directory.

---

## Uninstall

```bash
bash ~/.skills-agent/skills-agent/uninstall.sh
```

Removes all installed components.

---

## Troubleshooting

### "Authentication failed" (HTTPS)

**Cause:** Using GitHub password instead of Personal Access Token

**Solution:** Create token at https://github.com/settings/tokens with **repo** scope, use as password

### "Permission denied (publickey)" (SSH)

**Cause:** SSH key not added to GitHub

**Solution:** 
```bash
cat ~/.ssh/id_ed25519.pub
# Add to: https://github.com/settings/keys
```

### "Repository not found"

**Cause:** No access to private repository

**Solution:** Contact repository owner to grant access

### MCP Server Not Connected

1. Restart OpenCode completely
2. Check: `opencode mcp list`
3. Check logs: `~/.skills-agent/skills-agent/mcp.log`

---

## Manual Installation

If you prefer manual steps:

**With SSH:**
```bash
git clone git@github.com:defrindr/skills-agent.git ~/.skills-agent
cd ~/.skills-agent/skills-agent
npm install && npm run build && npm run setup
```

**With HTTPS:**
```bash
git clone https://github.com/defrindr/skills-agent.git ~/.skills-agent
# Enter username and Personal Access Token when prompted
cd ~/.skills-agent/skills-agent
npm install && npm run build && npm run setup
```

---

## Repository Access

This installer requires access to the private repository.

If you don't have access:
1. Request access from the repository owner
2. Wait for invitation email
3. Accept invitation
4. Setup SSH key or Personal Access Token
5. Run installer again

---

## Update

To update to the latest version:

```bash
cd ~/.skills-agent
git pull
cd skills-agent
npm install && npm run build && npm run setup
```

Then restart OpenCode.

---

## Support

For issues or questions, contact the repository owner.

---

## License

See main repository for license information.
