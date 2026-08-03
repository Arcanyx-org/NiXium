{ config, lib, nixosConfig, ... }:

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.programs.steam.enable (mkMerge [
	(mkIf config.home.impermanence.enable {
		home.persistence."/nix/persist/users/kira" = {
			stripHomePrefix = true;
			directories = [
				".steam"
			];
		};
	})
])
