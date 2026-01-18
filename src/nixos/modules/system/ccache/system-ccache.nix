{ lib, config, ... }:

# Set up CCache if it's enabled as instructed in https://nixos.wiki/wiki/CCache#NixOS

let
	inherit (lib) mkIf;
in mkIf config.programs.ccache.enable {
	nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		# CCache
		(mkIf config.programs.ccache.enable {
			directory = config.programs.ccache.cacheDir;
			user = "root";
			group = "nixbld";
			mode = "u=,g=rwx,o=";
		})
	];
}
