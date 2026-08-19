#!/usr/bin/env bash
#
# dotfiles installer.
#
#   ./install.sh                 full install (shell fragments + commands)
#   ./install.sh --commands-only only the Claude Code slash commands
#   ./install.sh --copy          copy commands instead of symlinking
#   ./install.sh --dry-run       print what would happen, change nothing
#
# Can also be piped:  curl -fsSL <raw-url>/install.sh | bash -s -- --commands-only
#
set -euo pipefail

COMMANDS_ONLY=0
DRY_RUN=0
LINK_MODE="symlink"
REPO_URL="https://github.com/Hanzi-Cho/dotfiles.git"

for arg in "$@"; do
  case "$arg" in
    --commands-only) COMMANDS_ONLY=1 ;;
    --copy)          LINK_MODE="copy" ;;
    --dry-run)       DRY_RUN=1 ;;
    -h|--help)       sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

run() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "  would run: $*"
  else
    "$@"
  fi
}

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m warn\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# Locate the repo. When piped through curl there is no checkout, so clone one.
# ---------------------------------------------------------------------------
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  DOTFILES_DIR="$HOME/.dotfiles"
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "updating existing checkout at $DOTFILES_DIR"
    run git -C "$DOTFILES_DIR" pull --ff-only
  else
    info "cloning $REPO_URL -> $DOTFILES_DIR"
    run git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
  fi
fi
info "dotfiles: $DOTFILES_DIR"

# ---------------------------------------------------------------------------
# Claude Code slash commands
# ---------------------------------------------------------------------------
SRC_CMDS="$DOTFILES_DIR/.claude/commands"
DST_CMDS="$HOME/.claude/commands"

if [ -d "$SRC_CMDS" ]; then
  info "installing Claude Code slash commands -> $DST_CMDS ($LINK_MODE)"
  run mkdir -p "$DST_CMDS"
  for src in "$SRC_CMDS"/*.md; do
    [ -e "$src" ] || continue
    name="$(basename "$src")"
    dst="$DST_CMDS/$name"

    # Back up a real file we did not create; leave our own symlink alone.
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      warn "$name already exists — backing up to $name.bak"
      run cp "$dst" "$dst.bak"
    fi

    if [ "$LINK_MODE" = "symlink" ]; then
      run ln -sfn "$src" "$dst"
    else
      run cp -f "$src" "$dst"
    fi
    echo "    Claude: /${name%.md}"
  done
else
  warn "no .claude/commands directory found — skipping Claude commands"
fi

# ---------------------------------------------------------------------------
# Antigravity (AGY) custom skills
# ---------------------------------------------------------------------------
SRC_SKILLS="$DOTFILES_DIR/.agents/skills"
DST_SKILLS="$HOME/.gemini/config/skills"

if [ -d "$SRC_SKILLS" ]; then
  info "installing Antigravity skills -> $DST_SKILLS ($LINK_MODE)"
  run mkdir -p "$DST_SKILLS"
  for skill_dir in "$SRC_SKILLS"/*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    dst_skill_dir="$DST_SKILLS/$skill_name"

    if [ "$LINK_MODE" = "symlink" ]; then
      run ln -sfn "$skill_dir" "$dst_skill_dir"
    else
      run mkdir -p "$dst_skill_dir"
      run cp -rf "$skill_dir"/* "$dst_skill_dir"/
    fi
    echo "    Antigravity: /$skill_name"
  done
fi

if [ "$COMMANDS_ONLY" = "1" ]; then
  info "done. Slash commands and skills are picked up by new Claude Code and Antigravity sessions."
  exit 0
fi

# ---------------------------------------------------------------------------
# Local secrets file — real values live outside the repo
# ---------------------------------------------------------------------------
SECRETS="$HOME/.dotfiles.secrets.sh"
if [ ! -f "$SECRETS" ]; then
  info "creating $SECRETS from template"
  run cp "$DOTFILES_DIR/secrets.example.sh" "$SECRETS"
  run chmod 600 "$SECRETS"
  warn "fill in $SECRETS (API keys, ANDROID_HOME, CLAUDE_WIN_HOME, ...)"
else
  info "keeping existing $SECRETS"
fi

# ---------------------------------------------------------------------------
# Shell loader — one idempotent block appended to the rc file
# ---------------------------------------------------------------------------
install_loader() {
  local rc="$1" frag_dir="$2"
  local marker="# >>> dotfiles loader >>>"

  [ -d "$DOTFILES_DIR/$frag_dir" ] || return 0

  if [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
    info "loader already present in $rc"
    return 0
  fi

  info "appending loader to $rc (sources $frag_dir/)"
  if [ "$DRY_RUN" = "1" ]; then
    echo "  would append loader block"
    return 0
  fi

  cat >>"$rc" <<EOF

$marker
export DOTFILES_DIR="$DOTFILES_DIR"
[ -f "\$HOME/.dotfiles.secrets.sh" ] && . "\$HOME/.dotfiles.secrets.sh"
for _f in "\$DOTFILES_DIR/$frag_dir"/*.sh; do
  [ -r "\$_f" ] && . "\$_f"
done
unset _f
# <<< dotfiles loader <<<
EOF
}

install_loader "$HOME/.bashrc" "bashrc.d"
[ -n "${ZDOTDIR:-}" ] && ZRC="$ZDOTDIR/.zshrc" || ZRC="$HOME/.zshrc"
[ -f "$ZRC" ] && install_loader "$ZRC" "zshrc.d"

info "done. Open a new shell, or: source ~/.bashrc"
warn "secrets are sourced BEFORE the fragments — set ANDROID_HOME etc. in $SECRETS"
