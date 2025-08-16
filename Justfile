# Rebuild current host
rebuild:
    sudo nix flake update
    sudo nixos-rebuild switch --flake .#betania
