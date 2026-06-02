{ inputs, ... }:

{
	# Flake lib export — takes pkgs (system-specific) and returns the mkScript function:
	#   let ms = nixium.lib.mkScript pkgs; in ms { name = "foo"; text = "..."; }
	flake.lib.mkScript = pkgs:
		(import ./lib-mkScript.nix {
			lib    = pkgs.lib;
			inherit pkgs;
			stdenv = pkgs.stdenv;
		}).mkScript;
}
