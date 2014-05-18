# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  packageGroups = import ./package-groups.nix {inherit pkgs;};
  secrets = import ./secrets.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./znc-server.nix
    ];

  ### BOOT & FILESYSTEMS ###

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  ### NETWORKING ###

  networking.hostName = "nixos";
  networking.wireless.enable = true;
  networking.firewall.allowPing = false;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 5000
  ];

  ### SYSTEM APPS ###

  environment = {
    systemPackages = with packageGroups;
      [ adminTools ];
  };

  ### SYSTEM SERVICES ###

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.znc = {
    enable = true;
    user = "chexxor";
    #extraFlags = "--debug";
  };
 
  services.ddclient = {
    enable = true;
    protocol = "noip";
    web = "";
    username = secrets.noip-username;
    password = secrets.noip-password;
    server = "dynupdate.no-ip.com";
    domain = secrets.chexxorDomainName;
  };

  /* !!! Spend time later to make this work.
  services.openvpn.enable = true;
  services.openvpn.servers = {
    alexvpn = {
      autoStart = true;
      config = ''
        dev tun
        ifconfig 10.8.0.1 10.8.0.2
        secret /root/static.key
      '';
      # up = "ip route add...";
      # down = "ip route del ...";
    };
  };
  */

  ### USERS ###

  users = {

    mutableUsers = false;

    extraGroups = [ {
      name = "chexxor";
      gid = 499;
    } {
      name = "dev";
      gid = 498;
    } ];

    extraUsers = [ {
      description = "chexxor";
      name = "chexxor";
      group = "chexxor";
      password = secrets.chexxorPass;
      extraGroups = [ "users" "wheel" ];
      home = "/home/chexxor";
      createHome = true;
      useDefaultShell = true;
      uid = 499;
    } ];
  };

  ### HARDWARE ###

  # Don't shutdown when lid closes. Machine is closet netbook.
  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  ### MISC ###

  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  time.timeZone = "America/Chicago";

}
