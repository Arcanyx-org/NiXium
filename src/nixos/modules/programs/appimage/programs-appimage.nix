{ lib, config, pkgs, ... }:

#! System Appimage Management

let
	inherit (lib) mkIf;
in mkIf config.programs.appimage.enable {
	programs.appimage = {
		binfmt = true;
		package = pkgs.appimage-run.override {
			extraPkgs = pkgs: [
				# Some packages need this dependency, added for utility - https://github.com/NixOS/nixpkgs/issues/350383#issuecomment-2433316461
				pkgs.libepoxy

				# Required by CrealityPrint 7.0.0.4127
				# pkgs.libdeflate
				# pkgs.bzip2

				# Required by OrcaSlicer 2.3.1
				pkgs.webkitgtk_4_1
			];
		};
	};
}
