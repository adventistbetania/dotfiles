{ config, lib, pkgs, ... }:

with lib;

{
  options.services.remoteDesktop = {
    enable = mkEnableOption "remote desktop services with GNOME and XRDP";
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the firewall for XRDP";
    };

    disableSuspend = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to disable system suspend/sleep features";
    };
  };

  config = mkIf config.services.remoteDesktop.enable {
    services = {
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      xrdp = {
        enable = true;
        defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
        openFirewall = config.services.remoteDesktop.openFirewall;
      };

      gnome.gnome-remote-desktop.enable = true;
      getty.autologinUser = null;
      displayManager.autoLogin.enable = false;
    };

    systemd = mkIf config.services.remoteDesktop.disableSuspend {
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
  };
}
