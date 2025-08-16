{
  description = "Betania's NixOS Configuration";
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.betania = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./modules/remote_desktop.nix
        ({ pkgs, ... }: {
          # Bootloader
          boot.loader.grub = {
            enable = true;
            device = "/dev/sda";
            useOSProber = true;
          };

          # Networking
          networking.hostname = "betania";
          networking.networkmanager.enable = true;

          # User
          users.users.admin = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "docker" ];
            password = "admin";
          };
          security.sudo.wheelNeedsPassword = false;

          # Services
          services = {
            remoteDesktop.enable = true;
            tailscale.enable = true;
          };

          # Docker
          virtualisation = {
            docker.enable = true;
          };

          environment.systemPackages = with pkgs; [
            git
            just
            zsh
          ];

          time.timeZone = "Europe/Bucharest";

          nixpkgs.config.allowUnfree = true;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          system.stateVersion = "25.05";
          })
        ];
      };
    };
}