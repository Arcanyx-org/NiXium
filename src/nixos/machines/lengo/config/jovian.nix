{ config, pkgs, lib, ... }:

# Jovian management of LENGO

let
	inherit (lib) mkIf;
in mkIf config.jovian.devices.legiongo.enable {
	# NOTE(Krey): Best Effort Implementation, doesn't work sufficiently
	jovian.steam.desktopSession = "gnome";

	jovian.steam = {
		user = "kira";
		enable = true;
		autoStart = true;
	};

	jovian.decky-loader = {
		user = "kira";
		enable = true;
	};

	programs.steam = {
		enable = true;
		extest.enable = true;
		remotePlay.openFirewall = true;
		extraCompatPackages = [
			pkgs.proton-ge-bin
		];
	};

	# hardware.steam-hardware.enable = false;

	# Enable CEF mode as currently it's required to get UI to load (https://github.com/Jovian-Experiments/Jovian-NixOS/issues/460)
		systemd.services.setUserPersistPermissions = {
			description = "Enable CEF Mode for Steam UI";
			wantedBy = [ "multi-user.target" ];
			after = [ "local-fs.target" ];  # Ensure this runs after the filesystem is mounted
			script = builtins.concatStringsSep "\n" [
				"${pkgs.su}/bin/su kira --command '${pkgs.coreutils}/bin/touch /home/kira/.steam/steam/.cef-enable-remote-debugging'"
			];
		};
}
