{ ... }:

let
	inherit (builtins) concatStringsSep;
in {
	# Enable required experimental features
	nix.extraOptions = concatStringsSep "\n" [
		''extra-experimental-features = nix-command flakes''
		''abort-on-warn = true''
	];
}
