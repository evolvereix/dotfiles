<samp><b>Dotfiles</b></samp>

<sub><samp>Personal macOS setup for terminal, developer tools, editors, and app preferences.</samp></sub>

<br>

<p align="center"><samp>Preview</samp></p>

<p align="center">
  <img alt="VS Code Preview" src="https://github.com/evolvereix/dotfiles/assets/37773107/76759752-79b9-4f7f-a84d-25ced44d4d72">
</p>

## 快速开始

```bash
git clone git@github.com:evolvereix/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles

chmod +x install.sh
./install.sh
```

安装脚本可以重复执行。目标配置文件已经存在且内容不同时，脚本会先备份到：

```text
~/.dotfiles-backup/<timestamp>/
```

如果只想同步配置文件：

```bash
./install.sh --configs-only
```

## 安装参数

查看完整帮助：

```bash
./install.sh --help
```

常用模式：

```bash
# 新机器完整初始化
./install.sh

# 只同步 dotfiles 和应用配置
./install.sh --configs-only

# 安装软件包，但跳过 VS Code 扩展安装
./install.sh --skip-vscode-extensions

# 指定本次备份目录
DOTFILES_BACKUP_DIR=~/Desktop/dotfiles-backup ./install.sh --configs-only
```

可用参数：

- `--configs-only`: 只同步 dotfiles 和应用配置。
- `--skip-brew`: 跳过 Homebrew 安装和更新。
- `--skip-packages`: 跳过 `Brewfile` 软件包安装。
- `--skip-oh-my-zsh`: 跳过 Oh My Zsh 安装。
- `--skip-zsh-plugins`: 跳过 zsh 插件安装。
- `--skip-configs`: 跳过配置文件同步。
- `--skip-vscode-extensions`: 跳过 VS Code 推荐扩展安装。

## 脚本做什么

`install.sh` 会按顺序执行：

1. 检查当前系统是否为 macOS。
2. 检查并安装 Xcode Command Line Tools。
3. 安装或更新 Homebrew。
4. 使用 [config/homebrew/Brewfile](config/homebrew/Brewfile) 安装软件包。
5. 安装 Oh My Zsh。
6. 安装 [zsh/.zshrc](zsh/.zshrc) 中使用的插件：`git-open`、`zsh-autosuggestions`、`zsh-syntax-highlighting`。
7. 同步 dotfiles 和应用配置。
8. 如果 `code` CLI 可用，安装 VS Code 推荐扩展。

## 配置映射

| 仓库路径 | 安装位置 |
| --- | --- |
| `config/git/.gitconfig` | `~/.gitconfig` |
| `config/git/.gitignore` | `~/.config/git/.gitignore` |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zprofile` | `~/.zprofile` |
| `config/starship.toml` | `~/.config/starship.toml` |
| `config/mise/config.toml` | `~/.config/mise/config.toml` |
| `config/bat/config` | `~/.config/bat/config` |
| `config/btop/btop.conf` | `~/.config/btop/btop.conf` |
| `config/gh/config.yml` | `~/.config/gh/config.yml` |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` |
| `config/1Password/ssh/agent.toml` | `~/.config/1Password/ssh/agent.toml` |
| `config/nvim` | `~/.config/nvim` |
| `config/ghostty/config.ghostty` | `~/.config/ghostty/config` |
| `config/ghostty/themes` | `~/.config/ghostty/themes` |
| `config/ghostty/icons` | `~/.config/ghostty/icons` |
| `claude/settings.json` | `~/.claude/settings.json`（仅目标不存在时） |
| `claude/themes/anthracite.json` | `~/.claude/themes/anthracite.json` |
| `claude/themes/anthracite.jsonc` | `~/.claude/themes/anthracite.jsonc`（带注释的主题维护文件） |
| `codex/config.toml` | `~/.codex/config.toml`（仅目标不存在时） |
| `codex/themes/Anthracite.tmTheme` | `~/.codex/themes/Anthracite.tmTheme` |
| `config/opencode/tui.json` | `~/.config/opencode/tui.json` |
| `config/opencode/themes/anthracite.json` | `~/.config/opencode/themes/anthracite.json` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `vscode/extensions.json` | `~/Library/Application Support/Code/User/extensions.json` |

## 包含内容

终端环境：

- Ghostty 配置、主题和自定义图标。
- Oh My Zsh，以及 Git、VS Code、Xcode、`z`、`git-open`、autosuggestions、syntax highlighting 插件。
- Starship prompt。
- bat 的 Nord 主题、行号、git changes 和 header 样式。

开发工具：

- mise：Node.js 22、最新版 pnpm、最新版 Go 和 Java。
- Git 默认配置、别名、全局 ignore，以及基于 1Password SSH key 的 commit signing。
- Neovim：LazyVim、Material 主题和 Diffview 快捷键。
- GitHub CLI、Herdr 与 1Password SSH Agent 的非敏感配置。
- Claude Code、Codex 与 OpenCode 的基础 UI 配置和 Anthracite 主题。
- VS Code 设置和推荐扩展。

Homebrew 应用和工具：

- 常用命令行工具、开发工具和图形库。
- AI、终端、编辑器、网络、数据库及系统增强类应用。
- 浏览器、办公协作、设计、通信、音乐和效率类应用。

完整软件清单维护在 [Brewfile](config/homebrew/Brewfile) 中。

## 注意事项

- 新机器安装前，先检查 [config/git/.gitconfig](config/git/.gitconfig)，把示例 `user.signingkey` 换成自己的 1Password SSH signing key。
- [zsh/.zprofile](zsh/.zprofile) 默认会在所有登录 shell（含 `$SHELL -lc`）中开启本地代理，不需要的话可以删掉或调整 `shell_proxy`。
- VS Code 扩展只有在 `code` 命令可用时才会自动安装；否则脚本只会复制推荐扩展列表。
- Ghostty 源文件在仓库中叫 `config.ghostty`，安装时会写入 Ghostty 标准路径：`~/.config/ghostty/config`。
- Claude 和 Codex 的主配置只在目标文件不存在时安装，避免覆盖 Computer Use、插件信任状态和其他机器生成内容。
- 不要把 AI 工具的登录态、会话、缓存、hooks、provider API key、项目信任记录或本机生成状态加入仓库。

## 更新

```bash
cd ~/Developer/dotfiles
git pull

# 完整更新
./install.sh

# 只刷新本地配置
./install.sh --configs-only
```

## 更新 Brewfile

本机 Homebrew 软件变化后，可以用下面命令刷新仓库中的 Brewfile：

```bash
brew bundle dump --file=config/homebrew/Brewfile --force --no-describe --no-vscode
```

`--no-describe` 保持 Brewfile 无描述注释；`--no-vscode` 排除本机 VS Code 扩展。推荐扩展由 [vscode/extensions.json](vscode/extensions.json) 维护，并由 `install.sh` 单独安装。

刷新后检查依赖和差异：

```bash
brew bundle check --file=config/homebrew/Brewfile --no-upgrade
git diff -- config/homebrew/Brewfile
```

导出会包含本机的 tap 和信任配置，提交前应检查是否混入临时软件或仅供本机使用的自定义源。
