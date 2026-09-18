#!/bin/bash

dotfiles="$HOME/repos/dotfiles"
dotfilesDesktop="$HOME/repos/dotfiles/desktop"

desktopList=(
    "$HOME/.config/kitty"           # kitty terminal config
    "$HOME/.config/nvim"            # Neovim config
    "$HOME/.config/mpv/"            # mpv config
    "$HOME/.config/hypr/"           # Hyprland config
    "$HOME/.config/systemd/"        # systemd user services
    "$HOME/.config/waybar/"         # Waybar config
    "$HOME/.config/dunst/"          # Dunst config
    "$HOME/.config/ranger/"         # Ranger config
    "$HOME/.config/rofi/"           # Rofi config
    "$HOME/.config/fastfetch/"      # fastfetch
    "$HOME/.config/tmux/"           # tmux
    "$HOME/.config/wezterm/"        # wezterm
    "$HOME/.config/ruff/"           # ruff
    "$HOME/.config/environment.d/"  # Auth
    "$HOME/.config/quickshell/"     # quickshell
    "$HOME/.config/yazi/"           # yazi
)

homeList=(
    "$HOME/.zshrc"                  # zsh config
    "$HOME/.p10k.zsh"               # powerlevel10k config
    "$HOME/.vimrc"                  # vim config
    "$HOME/.XCompose"               # Greek Symbols
    "$HOME/.config/mimeapps.list"   # mimes
    )

case "$1" in

    --desktop)
        # directories on $Home
        for source in "${homeList[@]}"; do
            cp -r -u -v $source $dotfiles
        done

        echo "=== Syncing .config configurations ==="
        copied=false

        for source in "${desktopList[@]}"; do
            if [ -e "$source" ]; then
                # Get the basename for the destination
                basename=$(basename "$source")
                dest="$dotfilesDesktop/$basename"

                # Create parent directory if needed
                mkdir -p "$dotfilesDesktop/"

                if [ -d "$source" ]; then
                    output=$(rsync -avu --delete "$source/" "$dest/" 2>&1)
                else
                    output=$(rsync -avu "$source" "$dotfilesDesktop/" 2>&1)
                fi

                if [ -n "$output" ]; then
                    echo "Synced: $source -> $dest"
                    echo "$output" | grep -v "^sending incremental file list$" | grep -v "^$"
                    copied=true
                fi
            else
                echo "Warning: $source does not exist, skipping..."
            fi
        done

        if [ "$copied" = false ]; then
            echo "No changes detected - all files are up to date"
        fi

        echo "=== Desktop sync complete ==="
    ;;

    --laptop)

        cp -r -u -v  "$HOME/.config/hypr/" "$dotfiles/Laptop-configs/"
        cp -r -u -v  "$HOME/.config/waybar/" "$dotfiles/Laptop-configs/"
        cp -r -u -v  "$HOME/.config/hypr/" "$dotfiles/Laptop-configs/"

    ;;

    --retrive)

        echo "retrieving configs"
        rsync --info=progress2 -aAv --exclude={'hypr*','waybar','Laptop-configs','retired','.*', 'wrappedhl', 'README.md'} "$dotfiles" "$HOME/.config/"
        cp -r -u -v "$dotfiles/Laptop-configs/*" "$HOME/.config/"

    ;;

    *)
    echo "Chose an option --desktop --laptop --retrive"

esac

echo "All Done"
