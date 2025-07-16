#!/usr/bin/env bash
set -e

CONFIG_DIR="$HOME/.config"
CLONE_DIR="$HOME/.dotfiles_temp"

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing base-devel and git..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay &>/dev/null; then
    echo "==> Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -si --noconfirm
    popd
fi

echo "==> Installing packages..."
yay -S --needed --noconfirm \
    hyprland hyprpaper waybar wofi wlogout mako greetd grim slurp \
    xdg-desktop-portal-hyprland wl-clipboard xdg-utils \
    kitty zsh neovim tmux lazygit fzf starship \
    brave-bin wireguard-tools btop pavucontrol \
    ttf-jetbrains-mono-nerd \
    pipewire wireplumber pipewire-pulse ripgrep unzip zip tar \
    asusctl

echo "==> Cloning dotfiles..."
git clone https://github.com/km-rjun/dotfiles "$CLONE_DIR"

echo "==> Symlinking all folders to $CONFIG_DIR"
for folder in "$CLONE_DIR"/*; do
    [ -d "$folder" ] || continue
    name="$(basename "$folder")"
    target="$CONFIG_DIR/$name"

    if [[ -e "$target" ]]; then
        echo "--> Skipping $name (already exists)"
        continue
    fi

    echo "--> Linking $name"
    ln -s "$folder" "$target"
done

sudo systemctl enable greetd
# echo "==> Configuring greetd to autostart Hyprland"
# sudo mkdir -p /etc/greetd
# sudo tee /etc/greetd/config.toml >/dev/null <<EOF
# [terminal]
# vt = 1
#
# [default_session]
# command = "Hyprland"
# user = "$USER"
# EOF
#
#
# echo "✅ Done! Reboot to launch Hyprland with greetd."
