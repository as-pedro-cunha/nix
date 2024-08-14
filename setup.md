## 
sudo apt update && sudo apt upgrade
sudo apt install curl gnome-shell-extension-manager


## install twingate  (need to be used by sudo, so its not possible to use it with home-managertwingahm
)
curl -s https://binaries.twingate.com/client/linux/install.sh | sudo bash
twingate setup
twingate desktop-start

### Hack for making it prompt for the auth for the first time (after that this is not needed)
twingate stop
twingate start


## Copy the contens of git@github.com:as-pedro-cunha/nix.git inside ~/.config/home-manager
# Install nix
## Multi user with root
`sh <(curl -L https://nixos.org/nix/install) --daemon`
## Single user without root
`sh <(curl -L https://nixos.org/nix/install) --no-daemon`

# Install home-manager
```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

nix-channel --update

nix-shell '<home-manager>' -A install

```
## Add the line below to a nix.conf
At ~/.config/nix/nix.conf

`experimental-features = nix-command flakes`

## Install flake
`nix run home-manager/master -- init --switch`


## Set alacritty as the default terminal
`gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'`

## Install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
sudo usermod -aG docker $USER
### Open a new shell
newgrp docker
### To test
docker run hello-world

## Install homebrew (can be useful)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Set zsh as the default shell
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)

## Set the secrets in
~/.config/home-manager/.exports.*
### The format should be `export SECRET_NAME=SECRET_VALUE`

## Finish (in a new shell)
up
hm