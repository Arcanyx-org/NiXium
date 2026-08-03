{ config, lib, ... }:

# Global Program Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.programs.imports = [
		nixosModules.programs-appimage
		nixosModules.programs-git
		nixosModules.programs-htop
		nixosModules.programs-kexec
		nixosModules.programs-vim
		nixosModules.programs-wakeonlan
	];

	imports = [
		./appimage
		./git
		./htop
		./kexec
		./vim
		./wakeonlan
	];
}
