#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/config/homebrew/Brewfile"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

SKIP_BREW=false
SKIP_PACKAGES=false
SKIP_OH_MY_ZSH=false
SKIP_ZSH_PLUGINS=false
SKIP_CONFIGS=false
SKIP_VSCODE_EXTENSIONS=false

log_info() {
  printf "%b[INFO]%b %s\n" "$BLUE" "$NC" "$1"
}

log_success() {
  printf "%b[SUCCESS]%b %s\n" "$GREEN" "$NC" "$1"
}

log_warning() {
  printf "%b[WARNING]%b %s\n" "$YELLOW" "$NC" "$1"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$1" >&2
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --configs-only              Only sync dotfiles and app configs.
  --skip-brew                 Skip Homebrew install/update.
  --skip-packages             Skip Brewfile package installation.
  --skip-oh-my-zsh            Skip Oh My Zsh installation.
  --skip-zsh-plugins          Skip Oh My Zsh plugin installation.
  --skip-configs              Skip config file sync.
  --skip-vscode-extensions    Skip installing recommended VS Code extensions.
  -h, --help                  Show this help message.

Environment:
  DOTFILES_BACKUP_DIR         Backup directory for overwritten local files.
                              Default: ~/.dotfiles-backup/<timestamp>
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --configs-only)
        SKIP_BREW=true
        SKIP_PACKAGES=true
        SKIP_OH_MY_ZSH=true
        SKIP_ZSH_PLUGINS=true
        SKIP_VSCODE_EXTENSIONS=true
        ;;
      --skip-brew)
        SKIP_BREW=true
        ;;
      --skip-packages)
        SKIP_PACKAGES=true
        ;;
      --skip-oh-my-zsh)
        SKIP_OH_MY_ZSH=true
        ;;
      --skip-zsh-plugins)
        SKIP_ZSH_PLUGINS=true
        ;;
      --skip-configs)
        SKIP_CONFIGS=true
        ;;
      --skip-vscode-extensions)
        SKIP_VSCODE_EXTENSIONS=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

check_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This installer supports macOS only."
    exit 1
  fi
  log_success "Detected macOS."
}

install_xcode_tools() {
  log_info "Checking Xcode Command Line Tools..."

  if xcode-select -p >/dev/null 2>&1; then
    log_success "Xcode Command Line Tools are installed."
    return
  fi

  log_info "Starting Xcode Command Line Tools installation..."
  xcode-select --install || true

  if [[ -t 0 ]]; then
    log_warning "Finish the popup installer, then press any key to continue."
    read -r -n 1
    printf "\n"
  else
    log_warning "Rerun this script after Xcode Command Line Tools finish installing."
    exit 1
  fi
}

brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    printf "/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    printf "/usr/local/bin/brew"
  fi
}

ensure_homebrew_shellenv() {
  local brew_path shellenv_line shellenv_cmd

  brew_path="$(brew_bin || true)"
  if [[ -z "$brew_path" ]]; then
    log_error "Homebrew was not found after installation."
    exit 1
  fi

  shellenv_cmd="$("$brew_path" --prefix)/bin/brew shellenv"
  shellenv_line="eval \"\$($shellenv_cmd)\""

  if [[ ! -f "$HOME/.zprofile" ]] || ! grep -Fq "$shellenv_line" "$HOME/.zprofile"; then
    printf "\n%s\n" "$shellenv_line" >> "$HOME/.zprofile"
    log_success "Added Homebrew shellenv to ~/.zprofile."
  fi

  eval "$("$brew_path" shellenv)"
}

install_homebrew() {
  if [[ "$SKIP_BREW" == true ]]; then
    log_info "Skipping Homebrew setup."
    return
  fi

  log_info "Checking Homebrew..."
  if ! brew_bin >/dev/null 2>&1; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ensure_homebrew_shellenv
    log_success "Homebrew installed."
    return
  fi

  ensure_homebrew_shellenv
  log_info "Updating Homebrew..."
  brew update
  log_success "Homebrew is ready."
}

install_packages() {
  if [[ "$SKIP_PACKAGES" == true ]]; then
    log_info "Skipping Brewfile packages."
    return
  fi

  if [[ ! -f "$BREWFILE" ]]; then
    log_warning "Brewfile not found: $BREWFILE"
    return
  fi

  if ! command -v brew >/dev/null 2>&1; then
    log_error "brew is required to install packages. Run without --skip-brew first."
    exit 1
  fi

  log_info "Installing packages from Brewfile..."
  if brew bundle check --file="$BREWFILE" >/dev/null 2>&1; then
    log_success "Brewfile dependencies are already installed."
  else
    HOMEBREW_BUNDLE_NO_LOCK=1 brew bundle --file="$BREWFILE" --verbose
    log_success "Brewfile packages installed."
  fi
}

install_oh_my_zsh() {
  if [[ "$SKIP_OH_MY_ZSH" == true ]]; then
    log_info "Skipping Oh My Zsh."
    return
  fi

  log_info "Checking Oh My Zsh..."
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_success "Oh My Zsh is already installed."
    return
  fi

  log_info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  log_success "Oh My Zsh installed."
}

clone_or_update_plugin() {
  local name="$1"
  local repo="$2"
  local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

  if [[ -d "$target/.git" ]]; then
    log_info "Updating zsh plugin: $name"
    git -C "$target" pull --ff-only
    return
  fi

  if [[ -e "$target" ]]; then
    log_warning "Skipping $name because $target exists and is not a git repo."
    return
  fi

  log_info "Installing zsh plugin: $name"
  git clone --depth 1 "$repo" "$target"
}

install_zsh_plugins() {
  if [[ "$SKIP_ZSH_PLUGINS" == true ]]; then
    log_info "Skipping zsh plugins."
    return
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_warning "Oh My Zsh is not installed. Skipping plugins."
    return
  fi

  clone_or_update_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
  clone_or_update_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
  clone_or_update_plugin "git-open" "https://github.com/paulirish/git-open.git"
  log_success "Zsh plugins are ready."
}

backup_path_for() {
  local target="$1"
  local relative

  relative="${target#$HOME/}"
  printf "%s/%s" "$BACKUP_ROOT" "$relative"
}

backup_target() {
  local target="$1"
  local backup

  [[ -e "$target" || -L "$target" ]] || return

  backup="$(backup_path_for "$target")"
  mkdir -p "$(dirname "$backup")"
  cp -a "$target" "$backup"
  log_warning "Backed up $target to $backup"
}

sync_file() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    log_warning "Missing source file: $source"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    log_success "Unchanged: $target"
    return
  fi

  backup_target "$target"
  cp "$source" "$target"
  log_success "Synced: $target"
}

sync_dir() {
  local source="$1"
  local target="$2"

  if [[ ! -d "$source" ]]; then
    log_warning "Missing source directory: $source"
    return
  fi

  backup_target "$target"
  mkdir -p "$(dirname "$target")"
  rm -rf "$target"
  cp -R "$source" "$target"
  find "$target" -name ".DS_Store" -delete
  log_success "Synced: $target"
}

sync_configs() {
  if [[ "$SKIP_CONFIGS" == true ]]; then
    log_info "Skipping config sync."
    return
  fi

  log_info "Syncing configuration files..."

  sync_file "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
  sync_file "$DOTFILES_DIR/config/git/.gitignore" "$HOME/.config/git/.gitignore"
  sync_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  sync_file "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
  sync_file "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"
  sync_file "$DOTFILES_DIR/config/bat/config" "$HOME/.config/bat/config"
  sync_file "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
  sync_file "$DOTFILES_DIR/vscode/extensions.json" "$HOME/Library/Application Support/Code/User/extensions.json"

  sync_file "$DOTFILES_DIR/config/ghostty/config.ghostty" "$HOME/.config/ghostty/config"
  sync_dir "$DOTFILES_DIR/config/ghostty/themes" "$HOME/.config/ghostty/themes"
  sync_dir "$DOTFILES_DIR/config/ghostty/icons" "$HOME/.config/ghostty/icons"
}

install_vscode_extensions() {
  if [[ "$SKIP_VSCODE_EXTENSIONS" == true ]]; then
    log_info "Skipping VS Code extensions."
    return
  fi

  if ! command -v code >/dev/null 2>&1; then
    log_warning "VS Code CLI 'code' was not found. Copied recommendations only."
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_warning "python3 was not found. Skipping VS Code extension installation."
    return
  fi

  log_info "Installing recommended VS Code extensions..."
  python3 - "$DOTFILES_DIR/vscode/extensions.json" <<'PY' | while IFS= read -r extension; do
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fp:
    data = json.load(fp)

for extension in data.get("recommendations", []):
    print(extension)
PY
    [[ -n "$extension" ]] && code --install-extension "$extension" --force
  done

  log_success "VS Code extensions are ready."
}

main() {
  parse_args "$@"

  printf "===========================================\n"
  printf "      macOS dotfiles installer\n"
  printf "===========================================\n\n"

  check_macos

  if [[ "$SKIP_BREW" != true ]]; then
    install_xcode_tools
  fi

  install_homebrew
  install_packages
  install_oh_my_zsh
  install_zsh_plugins
  sync_configs
  install_vscode_extensions

  printf "\n===========================================\n"
  log_success "macOS setup is complete."
  printf "===========================================\n\n"
  log_info "Restart your terminal or run: source ~/.zshrc"
  log_info "Backups, if any, were written to: $BACKUP_ROOT"
}

main "$@"
