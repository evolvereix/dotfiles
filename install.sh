#!/bin/bash

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "此脚本仅支持 macOS 系统"
        exit 1
    fi
    log_success "检测到 macOS 系统"
}

# 安装 Xcode Command Line Tools
install_xcode_tools() {
    log_info "检查 Xcode Command Line Tools..."
    if ! xcode-select -p &> /dev/null; then
        log_info "安装 Xcode Command Line Tools..."
        xcode-select --install
        log_warning "请在弹出的对话框中点击 '安装'，然后按任意键继续..."
        read -n 1 -s
    else
        log_success "Xcode Command Line Tools 已安装"
    fi
}

# 安装 Homebrew
install_homebrew() {
    log_info "检查 Homebrew..."
    if ! command -v brew &> /dev/null; then
        log_info "安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加 Homebrew 到 PATH (Apple Silicon Mac)
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        log_success "Homebrew 安装完成"
    else
        log_success "Homebrew 已安装"
        log_info "更新 Homebrew..."
        brew update
    fi
}

# 安装软件包
install_packages() {
    log_info "安装软件包..."
    if [[ -f "$DOTFILES_DIR/config/homebrew/Brewfile" ]]; then
        cd "$DOTFILES_DIR/config/homebrew"
        brew bundle --verbose
        log_success "软件包安装完成"
    else
        log_warning "未找到 Brewfile，跳过软件包安装"
    fi
}

# 安装 Oh My Zsh
install_oh_my_zsh() {
    log_info "检查 Oh My Zsh..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "安装 Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh 安装完成"
    else
        log_success "Oh My Zsh 已安装"
    fi
}

# 安装 Zsh 插件
install_zsh_plugins() {
    log_info "安装 Zsh 插件..."
    
    # zsh-autosuggestions
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    # zsh-autocomplete
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete" ]]; then
        git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete
    fi

    # git-open
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-open" ]]; then
        git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-open
    fi
    
    log_success "Zsh 插件安装完成"
}

# 创建配置文件软链接
copy_configs() {
    log_info "复制配置文件..."
    
    # 创建必要的目录
    mkdir -p ~/.config/git
    mkdir -p ~/.config/mise
    
    # Git 配置
    if [[ -f "$DOTFILES_DIR/config/git/.gitconfig" ]]; then
        cp "$DOTFILES_DIR/config/git/.gitconfig" ~/.gitconfig
        log_success "已复制 Git 配置"
    fi
    
    if [[ -f "$DOTFILES_DIR/config/git/.gitignore" ]]; then
        cp "$DOTFILES_DIR/config/git/.gitignore" ~/.config/git/.gitignore
        log_success "已复制 Git 忽略文件"
    fi
    
    # Zsh 配置
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
        log_success "已复制 Zsh 配置"
    fi
    
    # Starship 配置
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        cp "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
        log_success "已复制 Starship 配置"
    fi
    
    # Mise 配置
    if [[ -f "$DOTFILES_DIR/config/mise/config.toml" ]]; then
        cp "$DOTFILES_DIR/config/mise/config.toml" ~/.config/mise/config.toml
        log_success "已复制 Mise 配置"
    fi
}

# 主函数
main() {
    echo "==========================================="
    echo "      macOS 环境快速搭建脚本"
    echo "==========================================="
    echo
    
    check_macos
    install_xcode_tools
    install_homebrew
    install_packages
    install_oh_my_zsh
    install_zsh_plugins
    copy_configs
    
    echo
    echo "==========================================="
    log_success "🎉 macOS 环境搭建完成！"
    echo "==========================================="
    echo
    log_info "请重启终端或运行 'source ~/.zshrc' 来应用新配置"
    echo
}

# 运行主函数
main "$@"
