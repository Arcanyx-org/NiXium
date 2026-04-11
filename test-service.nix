{ config, pkgs, lib, ... }:

{
  services.timelogger.enable = lib.mkEnableOption "Timelogger service";

  services.timelogger.serviceConfig = {
    Type = "simple";
    ExecStart = pkgs.writeShellApplication {
      name = "timelogger";
      bashOptions = [ "errexit" "nounset" ];
      text = ''
        while true; do
          echo "$(date): Service heartbeat" >> /var/log/timelogger.log
          sleep 60
        done
      '';
    };
    Restart = "always";
    RestartSec = 5;
  };

  # Security hardening for the service
  systemd.services.timelogger.serviceConfig.ProtectSystem = "strict";
  systemd.services.timelogger.serviceConfig.ProtectHome = true;
  systemd.services.timelogger.serviceConfig.PrivateTmp = true;
  systemd.services.timelogger.serviceConfig.NoNewPrivileges = true;
  systemd.services.timelogger.serviceConfig.PrivateDevices = true;
}