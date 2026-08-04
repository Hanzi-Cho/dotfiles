# PATH
export PATH="$HOME/.local/bin:$PATH"
[ -n "$DOTFILES_DIR" ] && export PATH="$DOTFILES_DIR/bin:$PATH"

# GUI apps under WSLg
export GIO_EXTRA_MODULES=/usr/lib/x86_64-linux-gnu/gio/modules
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# API keys and SSL_CERT_FILE live in ~/.dotfiles.secrets.sh — see secrets.example.sh
