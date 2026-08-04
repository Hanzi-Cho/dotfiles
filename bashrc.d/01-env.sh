# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PATH
export PATH="$HOME/.local/bin:$PATH"
[ -n "$DOTFILES_DIR" ] && export PATH="$DOTFILES_DIR/bin:$PATH"

# Java — honour JAVA_HOME from the local secrets file, else auto-detect JDK 17
if [ -z "$JAVA_HOME" ] && [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
fi
[ -n "$JAVA_HOME" ] && export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK — ANDROID_HOME comes from the local secrets file
[ -n "$ANDROID_HOME" ] && export PATH="$ANDROID_HOME/platform-tools:$PATH"

# npm global bin
if command -v npm >/dev/null 2>&1; then
  _npm_prefix="$(npm config get prefix 2>/dev/null)"
  [ -n "$_npm_prefix" ] && export PATH="$_npm_prefix/bin:$PATH"
  unset _npm_prefix
fi

# API keys and SSL_CERT_FILE live in ~/.dotfiles.secrets.sh — see secrets.example.sh
