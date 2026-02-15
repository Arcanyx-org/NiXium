{ config, lib, ... }:

let
	inherit (lib) mkIf;
in mkIf config.programs.direnv.enable {
	programs.direnv = {
		nix-direnv.enable = true; # Always use nix-direnv with direnv
	};

	# Impermanence
	home.persistence."/nix/persist/users/kreyren".directories = mkIf config.home.impermanence.enable [
		".local/share/direnv"
	];
}
