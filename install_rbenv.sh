#!/usr/bin/env bash
set -euo pipefail

log() { printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

# 1) Prereqs (Ubuntu/Debian)
if command -v apt-get >/dev/null 2>&1; then
  log "Updating apt and installing build tools + libs..."
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends \
    build-essential curl git ca-certificates pkg-config \
    autoconf bison \
    libssl-dev zlib1g-dev libreadline-dev libyaml-dev \
    libsqlite3-dev sqlite3 libxml2-dev libffi-dev \
    libgdbm-dev libgmp-dev libncurses5-dev
else
  log "Non-apt system detected. Please install compiler toolchain and dev libraries manually."
fi

# 2) Install rbenv
if [ ! -d "$HOME/.rbenv" ]; then
  log "Cloning rbenv..."
  git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
else
  log "rbenv already present; updating..."
  git -C "$HOME/.rbenv" pull --ff-only || true
fi

# 3) Install ruby-build (as rbenv plugin)
mkdir -p "$HOME/.rbenv/plugins"
if [ ! -d "$HOME/.rbenv/plugins/ruby-build" ]; then
  log "Cloning ruby-build plugin..."
  git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
else
  log "ruby-build already present; updating..."
  git -C "$HOME/.rbenv/plugins/ruby-build" pull --ff-only || true
fi

# 4) Shell configuration (append once)
add_init_lines() {
  local file="$1"
  local marker_start="# >>> rbenv setup >>>"
  local marker_end="# <<< rbenv setup <<<"
  if [ -f "$file" ] && grep -q "$marker_start" "$file"; then
    log "rbenv init already in $file"
    return
  fi
  log "Adding rbenv init to $file"
  {
    echo ""
    echo "$marker_start"
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
    echo 'eval "$(rbenv init -)"'
    echo "$marker_end"
  } >> "$file"
}

SHELL_NAME="$(basename "${SHELL:-bash}")"
case "$SHELL_NAME" in
  zsh) add_init_lines "$HOME/.zshrc" ;;
  bash|*) add_init_lines "$HOME/.bashrc" ;;
esac
# Also add to .profile for login shells
add_init_lines "$HOME/.profile"

# 5) Load rbenv into current session
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$("$HOME/.rbenv/bin/rbenv" init -)"

# 6) Determine latest stable Ruby and install
log "Finding latest stable Ruby..."
latest="$(rbenv install -l | sed 's/^ *//' | grep -E '^[0-9]+(\.[0-9]+){2}$' | tail -1)"
if [ -z "${latest:-}" ]; then
  echo "Could not detect latest Ruby version from ruby-build list." >&2
  exit 1
fi
log "Installing Ruby ${latest} (this can take a while)..."
# Speed up a bit and avoid installing docs
export RUBY_CONFIGURE_OPTS="--disable-install-doc"
# Use -s to skip if already installed
rbenv install -s "$latest"

# 7) Set global and verify
log "Setting global Ruby to ${latest}..."
rbenv global "$latest"
rbenv rehash

log "Installing bundler..."
gem install bundler --no-document
rbenv rehash

log "Verification:"
ruby -v
which ruby
rbenv versions
log "Done."

