# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Some git defaults
git config --global color.ui true
git config --global push.default simple

# Install nvm
echo "Installing nvm..."
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
nvm install stable
nvm alias default stable

# Centralize global npm packages for different node versions
# echo "prefix = /usr/local" > ~/.npmrc

# Apps
# apps=(
#   google-chrome
#   iterm2
# )

# Install apps to /Applications
# Default is: /Users/$user/Applications
# echo "installing apps..."
# brew install --cask --appdir="/Applications" ${apps[@]}

# Plugins
plugins=(
  tig
  git-open
  jq
  bat
  tree
  mcfly
  starship
  fig
  autojump
  zsh-autosuggestions
  zsh-syntax-highlighting
  pnpm
)

# Install plugins
echo "installing plugins..."
brew install ${plugins[@]}

# clone this repo
git clone https://github.com/algorizen/dotfiles ~/.dotfiles

# Make some commonly used folders
mkdir ~/Developer

# Source dot file
echo '. ~/.dotfiles/macos/.zshrc' >> ~/.zshrc
source ~/.zshrc
