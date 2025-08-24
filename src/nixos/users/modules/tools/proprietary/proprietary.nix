{ lib, ... }:

# User-wide configuration of proprietary packages

# DNM(Krey): This doesn't work for some reason?

let
	inherit (lib) getName;
	inherit (builtins) elem;
in {
	# Non-Free Allow List
	nixpkgs.config.allowUnfreePredicate = pkg: elem (getName pkg) [
		# FIXME(Krey): Using vscodium, no idea why this needs 'vscode' set
		"vscode"

		# FIXME(Krey): It's ET: Legacy, what's proprietary there?
		"etlegacy"
		"etlegacy-assets"
	];
}


