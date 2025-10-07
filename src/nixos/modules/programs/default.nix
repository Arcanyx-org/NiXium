{ config, lib, ... }:

# Global Program Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.programs.imports = [
		nixosModules.programs-git
		nixosModules.programs-htop
		nixosModules.programs-vim
		nixosModules.programs-wakeonlan
	];

	imports = [
		./git
		./htop
		./vim
		./wakeonlan
	];
}
