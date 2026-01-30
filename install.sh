#!/bin/bash

# Link dotfiles to home directory
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global

# Install useful CLI tools
npm install -g tldr

# Set up Git shortcuts
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status

echo "✅ Dotfiles installed successfully!"
