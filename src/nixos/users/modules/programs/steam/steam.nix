{ config, lib, nixosConfig, ... }:

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.programs.steam.enable (mkMerge [
	(mkIf config.home.impermanence.enable {
		home.persistence."/nix/persist/users/${config.home.username}" = {
			# Persist the whole Steam tree so install identity (package/steam_client_ubuntu12.installed)
			# and auth state survive reboot on tmpfs home. Without it, Steam re-downloads the client
			# each boot, churns install identity, and invalidates steam.token/auto-login.
			directories = [ ".local/share/Steam" ];
		};
	})
])
