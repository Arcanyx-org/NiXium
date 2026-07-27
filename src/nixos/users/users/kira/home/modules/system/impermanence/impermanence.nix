{ lib, config, ... }:

let
	inherit (lib) mkIf;
in {
	home.persistence."/nix/persist/users/kira" = mkIf config.home.impermanence.enable {
		directories = [];
		files = [];
	};
}
