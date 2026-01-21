# pr1

Create GitHub PRs with AI-generated descriptions from your commits.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/haidoan/pr-cli/main/install.sh | bash
```

**Requirements:** bash, curl, jq, [GitHub CLI](https://cli.github.com/) (authenticated)

## Uninstall

```bash
rm "$(which pr1)"          # remove binary
rm -rf ~/.pr1              # remove config (optional)
```

## Usage (No Config)

```bash
pr1                    # Create PR (prompts for AI setup on first run)
pr1 -t main            # Target main branch
pr1 --preview          # Preview without creating
```

## Usage (With Config)

Create optional per-repo config for consistent settings:

```bash
pr1 --init             # Creates .pr1.json template
```

**Example `.pr1.json`:**

```json
{
  "reviewers": ["alice", "bob"],
  "targetBranch": "main",
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

## License

MIT
