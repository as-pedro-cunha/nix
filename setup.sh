#!/bin/bash

## Basic setup
sudo apt update && sudo apt upgrade
sudo apt install curl gnome-shell-extension-manager

## Install Alacritty (required for later steps), install using the step below or install it using the Ubuntu App Store
sudo snap install alacritty --classic

## Optionals (did not tested yet to install via snap)
sudo snap install code --classic
sudo snap install dbeaver-ce
sudo snap install nordpass
sudo snap install remmina
sudo snap install slack --classic

## Install Twingate
curl -s https://binaries.twingate.com/client/linux/install.sh | sudo bash
twingate setup
twingate desktop-start

## Hack for initial authentication
twingate stop
twingate start

## Setup home-manager
mkdir -p ~/.config/home-manager

## Copy the contens of git@github.com:as-pedro-cunha/nix.git inside ~/.config/home-manager 
##  (if you already have git then you can clone it, if not git will be installed via home-manager)
### git clone git@github.com:as-pedro-cunha/nix.git ~/.config/home-manager

## Install Nix
if [ $(id -u) -eq 0 ]; then
    sh <(curl -L https://nixos.org/nix/install) --daemon
else
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

## Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

## Configure Nix
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

## Install flake
nix run home-manager/master -- init --switch

## Configure nix-direnv
mkdir -p ~/.config/direnv
echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' > ~/.config/direnv/direnvrc

## Set Alacritty as default terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'

## Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world

## Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Set Zsh as default shell
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)

## Set secrets
# TODO: Add your secrets to ~/.config/home-manager/.exports.*

## Finish setup
source ~/.zshrc
echo "Updating home-manager nixpkgs..."
up
echo "Installing packages..."
hm