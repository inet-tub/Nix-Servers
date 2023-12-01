#!/usr/bin/env bash

# https://nixos.org/manual/nixos/stable/index.html#sec-installing-from-other-distro

echo -e "\n\nInstalling the Nix Package Manager\n"

# Check if the group 'nixbld' exists, if not, create it
if ! getent group nixbld > /dev/null; then
    sudo groupadd -g 30000 nixbld
    sudo useradd -u 30000 -g nixbld -G nixbld nixbld
fi

# Get the Nix package manager
curl -L https://nixos.org/nix/install | sh
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Fetch the latest NixOS channel:
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

# Install the install tools
nix-env -f '<nixpkgs>' -iA nixos-install-tools

# Update flake lock file
nix --extra-experimental-features 'nix-command flakes' flake update --commit-lock-file --flake "git+file:///mnt/etc/nixos"

# Install the system
nixos-install --no-root-password --flake "git+file:///mnt/etc/nixos#${HOST_TO_INSTALL}"

umount -R /mnt
zpool export -a

echo -e "\n"

# Prompt the user for verification
while true; do
    read -rp "The installation procedure is now complete. Do you wish to reboot? (y/n): " user_input
    case $user_input in
        [Yy]*) break ;;
        [Nn]*)
            echo "Alright, staying up."
            exit 1
            ;;
        *) echo "Please enter 'y' or 'n'." ;;
    esac
done

reboot
