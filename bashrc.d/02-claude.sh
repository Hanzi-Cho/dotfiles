# Claude Code account switcher.
#
# Keeps two logged-in profiles side by side and swaps the active credentials.
# Useful when a work account and a team/personal account both have Claude Code
# access. Configure the variables below in ~/.dotfiles.secrets.sh.
#
#   CLAUDE_WIN_HOME    Windows home under WSL, holding the stored profiles
#   CLAUDE_WORK_LABEL  label printed when switching to the work profile
#   CLAUDE_TEAM_LABEL  label printed when switching to the team profile
#   CLAUDE_BIN         path to the claude binary (default: first on PATH)

_CLAUDE_PROFILE_HOME="${CLAUDE_WIN_HOME:-$HOME}"
_CLAUDE_ACTIVE_DIR="$HOME/.claude"
_CLAUDE_WORK_META="$HOME/.claude-work.json"
_CLAUDE_TEAM_META="$HOME/.claude-team.json"

_claude_bin() {
  # CLAUDE_INSECURE_TLS=1 disables Node TLS verification. Only for corporate
  # MITM proxies whose CA cannot be installed. Prefer SSL_CERT_FILE instead.
  if [ "${CLAUDE_INSECURE_TLS:-0}" = "1" ]; then
    NODE_TLS_REJECT_UNAUTHORIZED=0 "${CLAUDE_BIN:-claude}" "$@"
  else
    "${CLAUDE_BIN:-claude}" "$@"
  fi
}

_claude_switch() {
  local profile="$1"
  shift || true

  local source_dir=""
  local label=""
  local source_meta=""

  case "$profile" in
    work)
      source_dir="${_CLAUDE_PROFILE_HOME}/.claude-work"
      label="${CLAUDE_WORK_LABEL:-work}"
      source_meta="${_CLAUDE_WORK_META}"
      ;;
    team)
      source_dir="${_CLAUDE_PROFILE_HOME}/.claude-teams"
      label="${CLAUDE_TEAM_LABEL:-team}"
      source_meta="${_CLAUDE_TEAM_META}"
      ;;
    *)
      echo "usage: claude-work | claude-team"
      return 1
      ;;
  esac

  if [ ! -f "${source_dir}/.credentials.json" ]; then
    echo "❌ profile credentials not found: ${source_dir}/.credentials.json"
    return 1
  fi

  mkdir -p "${_CLAUDE_ACTIVE_DIR}"
  cp "${source_dir}/.credentials.json" "${_CLAUDE_ACTIVE_DIR}/.credentials.json" || return 1

  if [ -f "${source_meta}" ]; then
    cp "${source_meta}" "$HOME/.claude.json" || return 1
  fi

  echo "✅ switched to ${label}"
  _claude_bin "$@"
}

alias claude='_claude_bin'
alias claude-work='_claude_switch work'
alias claude-team='_claude_switch team'
