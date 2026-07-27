{ config, lib, nixosConfig, ... }:

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.programs.steam.enable (mkMerge [
	(mkIf config.home.impermanence.enable {
		home.persistence."/nix/persist/users/${config.home.username}" = {
			directories = [
				".local/share/Steam/steamapps/common"
				".local/share/Steam/steamapps/shadercache"
				".local/share/Steam/steamapps/workshop"
			];
		};
	})
])
