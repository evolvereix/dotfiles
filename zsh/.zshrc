export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

CASE_SENSITIVE="true"

plugins=(
  git
  git-open
  vscode
  xcode
  z
  zsh-autocomplete
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

shell_proxy() {
  export https_proxy=http://127.0.0.1:6152;
  export http_proxy=http://127.0.0.1:6152;
  export all_proxy=socks5://127.0.0.1:6153
}

# make aliases sudo-able
alias sudo='sudo '

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Some Tools
alias codebase="git open"
alias ping="ping -c 5"
alias ipi="ipconfig getifaddr en0"
alias getpass="openssl rand -base64 12"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
# mise
eval "$(mise activate zsh)"
# Starship
eval "$(starship init zsh)"
