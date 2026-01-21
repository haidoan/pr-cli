# pr1

Create GitHub PRs with AI-generated descriptions from your commits.

## Why pr1?

Writing PR descriptions is tedious. You already wrote commit messages explaining your changes — why write it again?

**Without pr1:**
```
1. Finish coding
2. git push
3. Open GitHub in browser
4. Click "New Pull Request"
5. Write title manually
6. Look through commits to remember what you changed
7. Write description summarizing changes
8. Add testing notes
9. Select reviewers
10. Click "Create"
```

**With pr1:**
```
1. Finish coding
2. Run: pr1
3. Done. PR created with AI-generated description.
```

pr1 analyzes your commits and diffs, generates a professional PR description using AI, and creates the PR — all in one command.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/haidoan/pr-cli/main/install.sh | bash
```

**Requirements:** bash, curl, jq, [GitHub CLI](https://cli.github.com/) (authenticated)

## Quick Start

```bash
pr1 --configure        # First time: select AI provider and enter API key
pr1                    # Create PR from current branch to develop
```
config file will be saved at ` ~/.pr1/config`

## Supported AI Providers

| Provider | API Key |
|----------|---------|
| Claude | [console.anthropic.com](https://console.anthropic.com/) |
| Gemini | [makersuite.google.com](https://makersuite.google.com/app/apikey) |
| OpenAI | [platform.openai.com](https://platform.openai.com/api-keys) |
| DeepSeek | [platform.deepseek.com](https://platform.deepseek.com/api_keys) |

## Usage

```bash
pr1                    # Create PR (current branch → develop)
pr1 -t main            # Create PR targeting main branch
pr1 -r "alice,bob"     # Add reviewers
pr1 -d                 # Create as draft
pr1 --preview          # Preview without creating
pr1 --configure        # Change AI provider
```

## Per-Repo Config (Optional)

Create `.pr1.json` for consistent team settings:

```bash
pr1 --init             # Creates .pr1.json template
```

**Example `.pr1.json`:**

```json
{
  "reviewers": ["alice", "bob"],
  "targetBranch": "main",
  "draft": false,
  "customPrompt": "Focus on security implications"
}
```

| Field | Description |
|-------|-------------|
| `reviewers` | Default reviewers for this repo |
| `targetBranch` | Default target branch (default: `develop`) |
| `draft` | Create as draft by default |
| `customPrompt` | Additional AI instructions |
| `excludeFiles` | Files to exclude from diff analysis |
| `ticketPattern` | Regex for ticket extraction from branch |
| `ticketUrl` | URL template for ticket links |

## Release Commands

Create release branches and PRs with version bumping:

```bash
pr1 release sprint    # Sprint release (minor bump: 1.2.0 → 1.3.0)
pr1 release hotfix    # Hotfix release (patch bump: 1.2.3 → 1.2.4)
```

**Sprint release** (`pr1 release sprint`):
- Branches from `develop`
- Creates `release/vX.Y.0` branch
- Runs `npm run release:minor`
- Creates PR to `main`

**Hotfix release** (`pr1 release hotfix`):
- Branches from `main`
- Creates `hotfix/vX.Y.Z` branch
- Runs `npm run release:patch`
- Creates PR to `main`

Both commands show a preview and ask for confirmation before making any changes.

## All Options

| Flag | Description |
|------|-------------|
| `-t, --target <branch>` | Target branch (default: develop) |
| `-r, --reviewers <users>` | Comma-separated reviewers |
| `-d, --draft` | Create as draft PR |
| `--title <title>` | Override PR title |
| `--preview` | Preview without creating |
| `--configure` | Reconfigure AI provider |
| `--init` | Create .pr1.json template |
| `-y, --yes` | Skip confirmation |
| `-h, --help` | Show help |

## Uninstall

```bash
rm "$(which pr1)"          # remove binary
rm -rf ~/.pr1              # remove config (optional)
```

## License

MIT
