#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Local machine configuration — secrets and machine-specific paths.
#
# This file is a TEMPLATE. Copy it out of the repo and fill it in:
#
#     cp secrets.example.sh ~/.dotfiles.secrets.sh
#     chmod 600 ~/.dotfiles.secrets.sh
#     $EDITOR ~/.dotfiles.secrets.sh
#
# install.sh does this for you. The real file lives at ~/.dotfiles.secrets.sh,
# OUTSIDE the repo, so it can never be committed by accident.
# ---------------------------------------------------------------------------

# --- API keys --------------------------------------------------------------
# export GOOGLE_API_KEY="..."
# export ANTHROPIC_API_KEY="..."

# --- Corporate TLS ---------------------------------------------------------
# Some corporate networks terminate TLS with their own CA. Point this at the
# CA bundle so curl/python trust it, instead of disabling verification.
# export SSL_CERT_FILE="$HOME/certs/corporate-ca.pem"

# Last resort: disables TLS verification for the `claude` CLI only.
# Leave this unset unless the CA bundle above genuinely cannot be made to work.
# export CLAUDE_INSECURE_TLS=1

# --- Claude Code profile switching ----------------------------------------
# Windows home directory, when running under WSL. The switcher reads stored
# credentials from $CLAUDE_WIN_HOME/.claude-work and /.claude-teams.
# export CLAUDE_WIN_HOME="/mnt/c/Users/<your-windows-username>"

# Labels printed on switch — set to whichever accounts you use.
# export CLAUDE_WORK_LABEL="you@company.com"
# export CLAUDE_TEAM_LABEL="you@team.com"

# Explicit path to the claude binary. Defaults to whatever is on PATH.
# export CLAUDE_BIN="/usr/local/bin/claude"

# --- Android / React Native ------------------------------------------------
# Under WSL, point this at the Windows SDK so adb talks to Windows-attached
# devices. bin/adb then proxies to adb.exe.
# export ANDROID_HOME="/mnt/c/Users/<your-windows-username>/AppData/Local/Android/Sdk"

# Override the JDK if the auto-detected one is wrong.
# export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# --- Misc ------------------------------------------------------------------
# WSL → Windows Cursor binary, for the `cursor` alias.
# export CURSOR_BIN="/mnt/c/Users/<your-windows-username>/AppData/Local/Programs/cursor/resources/app/bin/cursor.exe"

# Where the `devlog` helper reads its JSONL event files. Defaults to ~/.devlog/events.
# export DEVLOG_DIR="$HOME/.devlog/events"
