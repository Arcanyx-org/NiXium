{ config, lib, ... }:

# TUPAC-specific configuration of Sunshine

let
	inherit (lib) mkIf;
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture
	services.sunshine.openFirewall = true; # Open Firewall for local network
}
