# PR AI CLI v2

> AI-powered GitHub Pull Request creation with optional per-repo configuration

**Simple. Portable. Works out of the box. Configurable when you need it.**

## Features

- 🤖 **AI-generated descriptions** - Analyzes commits and code diffs
- 📁 **Optional per-repo config** - Customize reviewers, prompts, templates per project
- 🎫 **Auto ticket detection** - Extracts JIRA/ticket numbers from branches
- 🔄 **Multi-provider** - Claude, Gemini, or OpenAI
- 🌍 **Global install** - Works in any repo
- 🔐 **Secure** - API keys stored locally with restricted permissions

## Quick Install

```bash
# Download and install globally
curl -fsSL https://raw.githubusercontent.com/USER/pr-ai-cli/main/install.sh | bash

# Or clone and install
git clone https://github.com/USER/pr-ai-cli.git
cd pr-ai-cli
./install.sh
```

## Requirements

- bash, curl, jq
- [GitHub CLI](https://cli.github.com/) (`gh`) - authenticated

## Basic Usage (No Config Needed!)

```bash
# Just run it - works immediately after first-time AI setup
pr-ai

# Create PR to specific branch
pr-ai -t main

# Add reviewers on the fly
pr-ai -r "alice,bob"

# Preview without creating
pr-ai --preview

# Create draft PR
pr-ai -d
```

**That's it!** No `.pr-ai.json` required. The tool uses sensible defaults:
- Target branch: `develop`
- Reviewers: none (add with `-r` flag)
- Standard PR template

## Optional: Per-Repo Configuration

For teams who want consistent settings per project, create `.pr-ai.json`:

```bash
pr-ai --init   # Creates template .pr-ai.json
```

### Example `.pr-ai.json`

```json
{
  "reviewers": ["alice", "bob", "charlie"],
  "targetBranch": "main",
  "customPrompt": "Focus on security and performance"
}
```

### When to Use `.pr-ai.json`

✅ **Use it when:**
- Your team has designated reviewers per repo
- You always target a specific branch (not `develop`)
- You want custom AI instructions for your project type
- You want to exclude certain files from analysis

❌ **Skip it when:**
- You're the only contributor
- Reviewers vary per PR
- Default settings work fine

## Configuration

### Global Config (Required Once)

On first run, you'll be prompted to select an AI provider and enter your API key.

Stored at `~/.pr-ai/config`. Reconfigure anytime with:

```bash
pr-ai --configure
```

### Per-Repo Config (Optional)

Create `.pr-ai.json` in any repo root:

```bash
pr-ai --init
```

## .pr-ai.json Reference

| Field | Type | Description |
|-------|------|-------------|
| `reviewers` | `string[]` | Default reviewers for this repo |
| `targetBranch` | `string` | Default target branch (default: `develop`) |
| `draft` | `boolean` | Create as draft by default |
| `titlePrefix` | `string` | Prefix for all PR titles |
| `customPrompt` | `string` | Additional AI instructions |
| `excludeFiles` | `string[]` | Files to exclude from diff |
| `ticketPattern` | `string` | Regex for ticket extraction |
| `ticketUrl` | `string` | URL template for tickets |
| `template` | `object` | PR description template |

### Template Configuration

Customize PR description sections:

```json
{
  "template": {
    "sections": ["summary", "changes", "testing"],
    "customSections": [
      {
        "name": "Breaking Changes",
        "prompt": "List any breaking changes or write 'None'",
        "optional": true
      },
      {
        "name": "Security",
        "prompt": "Note any security implications",
        "optional": true
      }
    ]
  }
}
```

## Example Configurations

### Frontend Project

```json
{
  "reviewers": ["frontend-lead", "designer"],
  "targetBranch": "develop",
  "customPrompt": "Focus on component reusability, accessibility, and performance. Note any new dependencies.",
  "template": {
    "customSections": [
      {
        "name": "Screenshots",
        "prompt": "Remind to add screenshots: 'Please add screenshots of UI changes'",
        "optional": false
      }
    ]
  },
  "excludeFiles": ["package-lock.json", "dist/*"],
  "ticketPattern": "FE-[0-9]+"
}
```

### Backend API

```json
{
  "reviewers": ["backend-lead", "security-team"],
  "targetBranch": "main",
  "customPrompt": "Focus on security, database performance, and backward compatibility.",
  "template": {
    "customSections": [
      {
        "name": "API Changes",
        "prompt": "List endpoint changes: method, path, description. Write 'None' if no API changes.",
        "optional": false
      },
      {
        "name": "Migration",
        "prompt": "Describe database migrations. Write 'None' if no migrations.",
        "optional": true
      }
    ]
  },
  "ticketPattern": "BE-[0-9]+"
}
```

### Mobile App

```json
{
  "reviewers": ["mobile-lead", "qa"],
  "targetBranch": "develop",
  "draft": true,
  "customPrompt": "Consider app size, battery usage, and offline functionality.",
  "template": {
    "customSections": [
      {
        "name": "Platforms",
        "prompt": "List affected platforms: iOS, Android, or Both",
        "optional": false
      }
    ]
  },
  "excludeFiles": ["Podfile.lock", "Pods/*"],
  "ticketPattern": "MOB-[0-9]+"
}
```

## Priority Order

Configuration is applied in this order (later overrides earlier):

1. **Defaults** - Built-in defaults
2. **Repo config** - `.pr-ai.json` in repo
3. **CLI arguments** - Command line flags

```bash
# .pr-ai.json has reviewers: ["alice", "bob"]
# This overrides to use charlie instead:
pr-ai -r "charlie"
```

## How It Works

```
┌─────────────────┐
│  Your Branch    │
│  (3 commits)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Read Commits   │ ◄── git log target..HEAD
│  Read Diff      │ ◄── git diff target
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Load Config    │ ◄── .pr-ai.json (if exists)
│  + Custom Prompt│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  AI Generates   │ ◄── Claude / Gemini / OpenAI
│  Description    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Create PR      │ ◄── gh pr create
│  + Reviewers    │
└─────────────────┘
```

## Team Setup

### Basic (No Shared Config)

Each team member just installs and uses their own API key:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/pr-ai-cli/main/install.sh | bash
pr-ai  # Prompts for AI provider on first run
```

### With Shared Repo Config (Optional)

If you want consistent reviewers/settings across the team:

1. **Add config to repo:**
   ```bash
   pr-ai --init
   # Edit .pr-ai.json with team reviewers
   git add .pr-ai.json
   git commit -m "Add PR AI config"
   ```

2. **Team members install:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/USER/pr-ai-cli/main/install.sh | bash
   ```

3. **Each member provides their own API key** on first run.

## All Options

```
pr-ai [OPTIONS]

OPTIONS:
    -t, --target <branch>    Target branch (default: from config)
    -r, --reviewers <users>  Comma-separated reviewers
    -d, --draft              Create as draft PR
    --title <title>          Override PR title
    --preview                Preview without creating
    --configure              Reconfigure AI provider
    --init                   Create .pr-ai.json template
    -y, --yes                Skip confirmation
    -v, --version            Show version
    -h, --help               Show help
```

## Troubleshooting

### "Command not found: pr-ai"

Add to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### "No commits found"

Make sure you have commits that differ from target:
```bash
git log develop..HEAD --oneline
```

### API errors

Check your config:
```bash
cat ~/.pr-ai/config
pr-ai --configure  # to reconfigure
```

### Config not loading

Check file location and JSON syntax:
```bash
cat .pr-ai.json | jq .
```

## VS Code Integration

Add JSON schema for autocomplete in `.pr-ai.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/USER/pr-ai-cli/main/schema.json",
  "reviewers": ["..."]
}
```

## License

MIT
# pr-cli
