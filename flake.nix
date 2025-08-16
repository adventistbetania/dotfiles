{
  description = "Betania's NixOS Configuration";
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.betania = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ({ pkgs, ... }: {
          # Bootloader
          boot.loader.grub = {
            enable = true;
            device = "/dev/sda";
            useOSProber = true;
          };

          # Networking
          networking.hostName = "betania";
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
            xserver.enable = true;
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
            
            xrdp = {
              enable = true;
              defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
              openFirewall = true;
            };
            
            gnome.gnome-remote-desktop.enable = true;
            getty.autologinUser = null;
            displayManager.autoLogin.enable = false;
            tailscale.enable = true;
          };

          # Disable suspend/sleep features
          systemd = {
            targets = {
              sleep.enable = false;
              suspend.enable = false;
              hibernate.enable = false;
              hybrid-sleep.enable = false;
            };
            
            services = {
              "getty@tty1".enable = false;
              "autovt@tty1".enable = false;
            };
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