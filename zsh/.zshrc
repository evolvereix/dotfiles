export ZSH="$HOME/.oh-my-zsh"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

typeset -U path

# PATH 优先级：~/.local/bin > pnpm > ai-drw > 系统目录
# （shell 按从左到右的顺序找命令，几个目录里有同名命令时，用最左边那个）
export PNPM_HOME="$HOME/Library/pnpm"
path=("$HOME/.local/bin" "$PNPM_HOME" "$HOME/.ai-drw/bin" $path)

plugins=(
  git
  git-open
  vscode
  xcode
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Codex 双通道：每次启动显式指定 provider，不跟随 thread 持久化的值，
# 同一个 thread 可以在两者之间来回 resume。
#   codex    → 个人 ChatGPT 订阅（-c model_provider=openai）；参数里带 -p/--profile 时不追加，交给 profile 决定
#   codex-gw → 公司网关（--profile game，provider 定义在主 config.toml）
# - 参数可以直接粘 Desktop 的 deeplink（codex://threads/<id>），会去掉前缀只留 thread id。
# - -c 优先级高于 --profile：codex/codex-gw 再带 -c model_provider=... 会改掉通道。
# - thread 在 ChatGPT Desktop 里打开过时，需先退出 App，终端才能 resume（active writer）。
unalias codex 2>/dev/null
codex() {
  local -a args=("${@#codex://threads/}")
  if (( ${args[(I)(-p|-p?*|--profile|--profile=*)]} )); then
    command codex "${args[@]}"
  else
    command codex -c model_provider=openai "${args[@]}"
  fi
}
codex-gw() { command codex -p game -c model_provider=game "${@#codex://threads/}"; }

# make aliases sudo-able
alias sudo='sudo '

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Some Tools
alias ping="ping -c 5"
alias ipi="ipconfig getifaddr en0"
alias getpass="openssl rand -base64 16"

# mise
eval "$(mise activate zsh)"
# Starship
eval "$(starship init zsh)"