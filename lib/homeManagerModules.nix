{ self, lib, flake-parts-lib, ... }:

# Module to manage home manager modules via flake-parts, credit sam sung (TODO: proper credit)

let
	inherit (lib)
		mapAttrs
		mkOption
		types
		;
	inherit (flake-parts-lib)
		mkSubmoduleOptions
		;
in
{
	options = {
		flake = mkSubmoduleOptions {
			homeManagerModules = mkOption {
				type = types.lazyAttrsOf types.unspecified;
				default = { };
				apply = mapAttrs (k: v: {
					_file = "${toString self.outPath}/flake.nix#homeManagerModules.${k}";
					imports = [ v ];
				});
				description = ''
					Home manager modules.

					You may use this for reusable pieces of configuration, service modules, etc.
				'';
			};
		};
	};
}
