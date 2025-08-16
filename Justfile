# Rebuild current host
rebuild:
    nix flake update
    sudo nixos-rebuild switch --flake .#betania
