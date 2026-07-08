{
	# NixOS modules that inject nixpkgs overlays
	#
	# These are modules that add overlays via nixpkgs.overlays, NOT
	# flake-level package overlays (which live in src/nixos/overlays/).
	flake.nixosModules.overlays = ../../overlays/modules/disk-image-memory.nix;
}
