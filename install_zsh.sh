#!/bin/bash

# Function to install a package if it is not already installed
install_package() {
  if ! brew list -1 | grep -q "$1"; then
    echo "Installing $1..."
    brew install $1
  else
    echo "$1 is already installed."
  fi
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed."
fi

# Install iTerm2
echo "Installing iTerm2..."
brew install --cask iterm2

echo "iTerm2 installation complete!"

# Install zsh
install_package zsh

arch=$(uname -m)
set_zsh=""

if [ "$arch" == "x86_64" ]; then
    echo "This is an Intel-based Mac."
    set_zsh="chsh -s /usr/local/bin/zsh"
elif [ "$arch" == "arm64" ]; then
    echo "This is an Apple Silicon-based Mac."
    set_zsh="chsh -s $(which zsh)"
else
    echo "Unknown architecture: $arch"
    exit 1
fi

# Change default shell to zsh
if [ -n "$set_zsh" ]; then
    echo "Setting default shell to zsh..."
    echo $set_zsh
    eval "$set_zsh"
else
    echo "Failed to set default shell."
    exit 1
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
else
    echo "oh-my-zsh is already installed."
fi

git submodule update --init --recursive



ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

# Copy plugins and themes from submodules
cp -r ./plugins/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
cp -r ./plugins/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
cp -r ./plugins/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
cp -r ./themes/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"


# Copy .zshrc
cp zshrc ~/.zshrc

# Apply changes
source ~/.zshrc

echo "Installation complete! Please restart your terminal."

open -a iTerm
