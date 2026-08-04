# About this repo

Personal dotfiles for a WSL2 + tmux + React Native / Android workflow, plus the
Claude Code slash commands in `.claude/commands/`.

# Ground rules

1. **Never commit secrets.** API keys, tokens, certificates and absolute paths
   containing a username belong in `~/.dotfiles.secrets.sh`, which lives outside
   this repo. `secrets.example.sh` documents every variable the shell fragments
   read; add new ones there as commented placeholders only.
2. Shell fragments must stay portable — no hardcoded `/home/<user>` or
   `/mnt/c/Users/<user>` paths. Use `$HOME`, `$DOTFILES_DIR`, or a variable
   sourced from the secrets file.
3. `bashrc.d/` and `zshrc.d/` are kept in sync deliberately. Change one, mirror
   the other.

# When suggesting changes

1. If a better established tool already exists, say so first.
2. If an approach is non-standard or overengineered, say so plainly.
3. Propose the better option before implementing the one that was asked for.
