{ self, pkgs, config, lib, aagl, ... }:

# LENGO-specific configuration of Sunshine

let
	inherit (lib) mkIf;
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture

	# NOTE(Krey): Sunsine doesn't work on the current kernel due to broken Xorg, it's possible to get working maybe through `cage`, but I would rather wait for more implemented kernel, for the time being disabling openFirewall as it's a security concern when it's not set up
	services.sunshine.openFirewall = false; # Open Firewall for local network
}
