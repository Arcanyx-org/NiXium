{ pkgs, ... }:

{
	# Enable required experimental features
	nix.extraOptions = builtins.concatStringsSep "\n" [
		"extra-experimental-features = nix-command flakes"
	];
}
