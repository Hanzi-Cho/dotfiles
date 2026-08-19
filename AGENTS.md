# Antigravity Operating Rules for dotfiles

This repository manages shell environments (bash/zsh), Claude Code slash commands (`.claude/commands/`), and Antigravity custom skills (`.agents/skills/`).

## Key Workflows & Shortcuts
- `/til` or `til: <content>`: Trigger TIL Daily(STAR) & Knowledge recording workflow.
- `/vault` or `vault: <content>`: Trigger Idea Vault classification & Tech Radar recording workflow.
- `/commit`: Atomic commit suggestion with Conventional Commits.
- `/summarize`: Summarize session history and promote principles to knowledge.

## Ground Rules
1. **Never commit secrets**: Real tokens and API keys go to `~/.dotfiles.secrets.sh`.
2. **Portability**: Keep shell scripts portable across WSL2/Linux/macOS using `$HOME`.
3. **Sync**: Keep `bashrc.d/` and `zshrc.d/` synchronized.
