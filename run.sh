#!/usr/bin/env bash
set -e

CONFIG_DIR="$HOME/.config"
CLONE_DIR="$HOME/.dotfiles_temp"

echo "Select Desktop Environment:"
echo "1) Hyprland"
echo "2) Niri"

while true; do
    read -rp "Enter choice (1 or 2): " DE_CHOICE
    case $DE_CHOICE in
        1)
            DE="hyprland"
            break
            ;;
        2)
            DE="niri"
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done

echo "==> Selected DE: $DE"

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

COMMON_PKGS=(
    kitty zsh neovim tmux lazygit fzf starship
    brave-bin wireguard-tools btop pavucontrol
    ttf-jetbrains-mono-nerd
    pipewire wireplumber pipewire-pulse
    ripgrep unzip zip tar
    wl-clipboard xdg-utils grim slurp mako greetd
)

HYPR_PKGS=(
    hyprland hyprpaper waybar wofi wlogout
    xdg-desktop-portal-hyprland
)

NIRI_PKGS=(
    niri
    noctalia-shell
)

echo "==> Installing packages..."

if [[ "$DE" == "hyprland" ]]; then
    yay -S --needed --noconfirm "${COMMON_PKGS[@]}" "${HYPR_PKGS[@]}"
else
    yay -S --needed --noconfirm "${COMMON_PKGS[@]}" "${NIRI_PKGS[@]}"
fi

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

echo "==> Setup complete!"

