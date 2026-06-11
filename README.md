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
| `config/starship.toml` | `~/.config/starship.toml` |
| `config/mise/config.toml` | `~/.config/mise/config.toml` |
| `config/bat/config` | `~/.config/bat/config` |
| `config/ghostty/config.ghostty` | `~/.config/ghostty/config` |
| `config/ghostty/themes` | `~/.config/ghostty/themes` |
| `config/ghostty/icons` | `~/.config/ghostty/icons` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `vscode/extensions.json` | `~/Library/Application Support/Code/User/extensions.json` |

## 包含内容

终端环境：

- Ghostty 配置、主题和自定义图标。
- Oh My Zsh，以及 Git、VS Code、Xcode、`z`、`git-open`、autosuggestions、syntax highlighting 插件。
- Starship prompt。
- bat 的 Nord 主题、行号、git changes 和 header 样式。

开发工具：

- mise：Node.js 22、最新版 pnpm、最新版 Go。
- Git 默认配置、别名、全局 ignore，以及基于 1Password SSH key 的 commit signing。
- VS Code 设置和推荐扩展。

Homebrew 应用和工具：

- `mise`、`starship`、`bat`
- 1Password、Surge、Ghostty、Claude、Claude Code、ChatGPT、Codex、Codex App
- Notion、CleanShot、RapidAPI、Fork、SF Symbols、Dia
- Visual Studio Code、IntelliJ IDEA、Android Platform Tools
- 飞书、Figma、Google Chrome、MWeb Pro、Eagle、WeChat

## 注意事项

- 新机器安装前，先检查 [config/git/.gitconfig](config/git/.gitconfig)，把示例 `user.signingkey` 换成自己的 1Password SSH signing key。
- [zsh/.zshrc](zsh/.zshrc) 默认会在交互式 shell 中开启本地代理，不需要的话可以删掉或调整 `shell_proxy`。
- VS Code 扩展只有在 `code` 命令可用时才会自动安装；否则脚本只会复制推荐扩展列表。
- Ghostty 源文件在仓库中叫 `config.ghostty`，安装时会写入 Ghostty 标准路径：`~/.config/ghostty/config`。

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
brew bundle dump --file=config/homebrew/Brewfile --force
```

提交前先检查 diff，避免把临时安装的软件写进去。
