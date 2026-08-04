# WSL → Windows binaries. CURSOR_BIN is set in ~/.dotfiles.secrets.sh.
[ -n "$CURSOR_BIN" ] && alias cursor="$CURSOR_BIN"
command -v explorer.exe >/dev/null 2>&1 && alias explorer='explorer.exe'

# devlog — tail today's JSONL event log. DEVLOG_DIR overrides the location.
unalias devlog 2>/dev/null
devlog() {
  local dir="${DEVLOG_DIR:-$HOME/.devlog/events}"
  local today="$dir/$(date +%Y-%m-%d).jsonl"
  local filter="${1:-today}"

  case "$filter" in
    today)
      cat "$today" 2>/dev/null
      ;;
    hour)
      cat "$today" 2>/dev/null | python3 -c "
import json, sys
from datetime import datetime, timezone, timedelta
cutoff = datetime.now(timezone.utc) - timedelta(hours=1)
for line in sys.stdin:
    try:
        d = json.loads(line)
        ts = datetime.fromisoformat(d['ts'])
        if ts >= cutoff:
            print(line, end='')
    except:
        pass
"
      ;;
    *)
      echo "usage: devlog [today|hour]" >&2
      return 1
      ;;
  esac
}
