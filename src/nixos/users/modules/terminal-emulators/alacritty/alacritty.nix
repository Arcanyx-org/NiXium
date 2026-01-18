{ lib, pkgs, ... }:

# Common Configuration of Alacritty

let
	inherit (lib) mkDefault;
in {
	programs.alacritty = {
		settings = {
			# FIXME-QA(Krey): This was changed in 24.11 on terminal.shell from shell, needs adjustments for release-independence
			terminal.shell = {
				program = mkDefault "${pkgs.bashInteractive}/bin/bash";
			};
		};
	};
}
