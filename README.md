<samp><b>Dotfiles</b></samp>

<sub><samp>&nbsp;&nbsp;My Mac Setup | <a href="https://blog.evolvereix.com/Mac-89c09a1c74e9487e85f8829bba3addf1">Mac</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</samp></sub>

<br>
<p align="center"><samp>Preview</samp></p>

<p align="center">
<img alt="VS Code Preview" src="https://github.com/evolvereix/dotfiles/assets/37773107/76759752-79b9-4f7f-a84d-25ced44d4d72">
</p>

<br>

## 🚀 快速开始

### 一键安装

```bash
# 克隆仓库
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 运行安装脚本
chmod +x install.sh
./install.sh
```

### 手动安装

如果你想要更多控制，可以分步骤执行：

```bash
# 1. 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装软件包
brew bundle --file=config/homebrew/Brewfile

# 3. 复制配置文件
./install.sh  # 或者手动复制配置文件
```

## 📦 包含的软件和配置

### 开发工具

- **Homebrew**: macOS 包管理器
- **mise**: 运行时版本管理器 (Node.js, Python 等)
- **Git**: 版本控制系统，包含自定义配置
- **Visual Studio Code**: 代码编辑器，包含扩展和设置
- **WebStorm**: JetBrains IDE

### 终端环境

- **Oh My Zsh**: Zsh 框架
- **Starship**: 跨平台命令行提示符
- **Zsh 插件**:
  - zsh-autosuggestions: 命令自动建议
  - zsh-syntax-highlighting: 语法高亮
  - zsh-autocomplete: 自动补全

### 应用程序

- **1Password**: 密码管理器
- **Arc**: 现代浏览器
- **CleanShot**: 截图工具
- **Raycast**: 启动器和生产力工具
- **Notion**: 笔记和协作工具
- **Trae**: AI 代码编辑器

### 主题和外观
- **iTerm2 主题**: Dracula, PaperColor, Solarized
- **VS Code 主题**: Vira 主题

## 🛠️ 自定义配置

### Git 配置

- 启用 GPG 签名 (使用 1Password SSH 密钥)
- 自定义别名和日志格式
- 全局 gitignore 文件

### Zsh 配置

- 自定义别名和函数
- 代理设置函数
- PNPM 路径配置

### VS Code 配置

- 精选的扩展包
- 优化的编辑器设置
- 代码格式化和 linting 配置

## 📁 目录结构

```
dotfiles/
├── install.sh              # 主安装脚本
├── config/
│   ├── git/               # Git 配置文件
│   ├── homebrew/          # Homebrew Brewfile
│   ├── mise/              # Mise 配置
│   └── starship.toml      # Starship 配置
├── vscode/                # VS Code 设置和扩展
├── zsh/                   # Zsh 配置
├── theme/                 # 终端主题文件
└── iterm/                 # iTerm2 配置
```

## 🔧 安装脚本功能

`install.sh` 脚本会自动执行以下操作：

1. **系统检查**: 验证是否为 macOS 系统
2. **Xcode Tools**: 安装 Xcode Command Line Tools
3. **Homebrew**: 安装 Homebrew 包管理器
4. **软件包**: 通过 Brewfile 安装所有应用和工具
5. **Oh My Zsh**: 安装 Zsh 框架和插件
6. **配置复制**: 复制所有配置文件到相应位置

## ⚠️ 注意事项

- 脚本会修改系统设置，请在运行前备份重要数据
- 某些应用可能需要手动登录和配置
- Git 配置中的 GPG 签名需要配置 1Password SSH 密钥
- 首次运行可能需要较长时间，取决于网络速度

## 🔄 更新配置

要更新配置，只需拉取最新代码并重新运行脚本：

```bash
cd ~/dotfiles
git pull
./install.sh
```
