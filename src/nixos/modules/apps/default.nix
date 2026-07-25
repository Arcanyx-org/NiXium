{ config, lib, ... }:

# Global Applications (system-level tools and packages)

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.apps.imports = [
		nixosModules.apps-kexec
	];

	imports = [
		./kexec
	];
}