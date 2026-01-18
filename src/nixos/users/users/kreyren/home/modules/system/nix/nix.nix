{ config, self, ... }:

# Kreyren's personal Nix Configuration

let
	inherit (builtins) concatStringsSep;
in {
	# Include GitHub API Token to avoid rate-limiting
		age.secrets.kreyren-github-access-token = {
			file = "${self.outPath}/src/nixos/users/users/kreyren/home/secrets/kreyren-github-access-token.age";
			path = "${config.home.homeDirectory}/.config/nix/kreyren-github-access-token";

			symlink = false;
		};
		nix.extraOptions = concatStringsSep "\n" [
			"!include ${config.age.secrets.kreyren-github-access-token.path}"
		];
}
