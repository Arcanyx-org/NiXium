{ inputs, ... }:

{
	# Flake lib export — pre-applied with nixpkgs.lib so external flakes can call directly:
	#   let inherit (nixium.lib) mkError; in throw (mkError { what = ...; why = ...; how = ...; })
	flake.lib.mkError = import ./lib-mkError.nix { lib = inputs.nixpkgs.lib; };
}
