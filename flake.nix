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
          networking.interfaces.eth0.ipv4.addresses = [
            {
              address = "192.168.0.128";  # Static IP address
              prefixLength = 24;
            }
          ];

          # SSH
          services.openssh.enable = true;

          # User
          users.users.admin = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "docker" ];
            password = "admin";
            openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUJWuWXCZpiPQSwRZgOU6baccQZ14+lTJqUeMtfNE1jZcvtucF++3S7CTH7mHngFbI71/Io+ICqEZAkYBnu72CMwPXOwFyj5nerhQK5uX6KWGcLMXYwH4v43jWVdv/Xe/Dk3xshD3yevgeGzgQZxmWlko6hgr+0sGU7eJBFbfx8ILKTOLbXSVyBCx5xK37vaa8x7ZUB7oASj0hLH6YXs+BjPpwQuXCnNx8exMwMWajfaJ5gqaIyZLxyXJxgt8gbMTeQNN8fbavxiZozWwFbC50kXcHR8lKsGvXgqA5WlU55RdYoEzSTWflw6bsyEaFNbXBt2asAVDNBMPS1/aP8vdlKolU1Sqd/dMFYu1WLQ+Q705G//+iwEWeiZpg/m9+8CSU6OD0toRaUneC11CmDXTJjS89giIbofpz900+j2WOcSbAOEGHjCEl+qDl4bWXndF9itqgblQjFDysgJ3ZI4PAR4OCB8GyNY5UUoKg2HAB8H50gNdV0pHS2ysPh8c3Me/cGfbBYVUjzzsmxEd4VGzCP098ippMpgK/K/Q9TFtuaxEZZ3jOb0/GU10JjatgWYfULzXyXRkyptZDkGyGR+6I0YfcEmFy8hInf1oXS8keDHGAxznXn3EhNXH6xQuaJM4zIOE60CUUdBC3Iz1T7Kmidc9BNDGz/ggJmnD66RzTBw=="
            ];
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