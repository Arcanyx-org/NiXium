{ config, lib, ... }:

let
	inherit (lib) mkIf;
in {
	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
		enableBashIntegration = true;
	};

	home.persistence."/nix/persist/users/kreyren".directories = mkIf config.home.impermanence.enable [
		".local/share/direnv"
	];
}
