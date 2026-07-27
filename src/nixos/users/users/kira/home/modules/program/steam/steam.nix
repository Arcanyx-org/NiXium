{ config, lib, nixosConfig, ... }:

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.programs.steam.enable (mkMerge [
	(mkIf config.home.impermanence.enable {
		home.persistence."/nix/persist/users/kira" = {
			files = [
				# Auth — persist so auto-login survives reboot
				# Steam rewrites these files through the symlinks to persistent storage
				".steam/steam.token"
				".local/share/Steam/config/loginusers.vdf"
				".local/share/Steam/config/config.vdf"
			];
			directories = [
				# localconfig.vdf (SharedAuth.AuthData for auto-login)
				# and other user-specific configs live here
				".local/share/Steam/userdata/343946311/config"
			];
		};
	})
])
