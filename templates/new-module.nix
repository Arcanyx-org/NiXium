{ lib, ... }:

# TITLe

let
	inherit (lib) mkIf mkMerge;
in mkIf ... (mkMerge [
		{

		}

		{
			"24.05" = {};
			"24.11" = {};
			"25.05" = {};
		}.${lib.trivial.release} or (throw "Release '${lib.trivial.release}' is not implemented in ...")
])
