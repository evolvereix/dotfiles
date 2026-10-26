# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# 代理：放在 .zprofile 是为了让 `$SHELL -lc`（如 Codex hooks）也能继承
shell_proxy() {
  export https_proxy=http://127.0.0.1:6152;
  export http_proxy=http://127.0.0.1:6152;
  export all_proxy=socks5://127.0.0.1:6153
}

unset_proxy() {
  unset https_proxy
  unset http_proxy
  unset all_proxy
}

shell_proxy

# Flux Island 的上报进程（Node）默认不走代理；开启后读取上面的 https_proxy。
export NODE_USE_ENV_PROXY=1
