{ config, lib, pkgs, ...}:

let
  cfg = config.services.znc;
  user = if cfg.user != null then cfg.user else "znc";

  # ??? Move these to `modules/misc/ids.nix` ?
  zncserverUid = 200;
  zncserverGid = 200;

in

with lib;

{

  ###### interface

  options = {
    services.znc = {
      enable = mkOption {
        default = false;
        example = true;
        type = with types; bool;
        description = ''
          Enable a ZNC service for a user.
        '';
      };

      user = mkOption {
        default = "root";
        example = "john";
        type = types.string;
        description = ''
          The user account to use when starting the ZNC server.
        '';
      };

      dataDir = mkOption {
        default = "/home/${cfg.user}/.znc";
        example = "/home/john/.znc";
        type = types.string; 
        description = ''
          The data directory. Used for configuration files and modules.
        '';
      };

      extraFlags = mkOption {
        default = "";
        example = "--debug";
        type = types.string;
        description = ''
          Extra flags to use when executing znc command.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.znc ];

    systemd.services."znc-${cfg.user}" = {
      description = "ZNC Server of ${cfg.user}.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.service" ];
      path = [ pkgs.znc ];
      script = "${pkgs.znc}/bin/znc --foreground --datadir ${cfg.dataDir} ${cfg.extraFlags}";
      serviceConfig.User = "${cfg.user}";
      preStart = ''
        mkdir -p ${cfg.dataDir}
        chown ${cfg.user} ${cfg.dataDir} -R
      '';
    };

    users.extraUsers = mkIf (cfg.user == null) [
      { name = "znc";
        description = "ZNC server daemon";
        group = "znc";
        #uid = config.ids.uids.zncserver;
        uid = zncserverUid;
      }];
 
    users.extraGroups = mkIf (cfg.user == null) [
      { name = "zncserver";
        #gid = config.ids.gids.zncserver;
        gid = zncserverGid;
      }];

  };
}