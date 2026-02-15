{ config, lib, pkgs, ... }:

# Global Home Configuration of Alacritty

let
	inherit (lib) elem optionalString mkDefault mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf config.programs.alacritty.enable (mkMerge [
	{
		"24.05" = {
			programs.alacritty.settings = {
				terminal.shell = {
					program = mkDefault "${pkgs.bashInteractive}/bin/bash";
				};
			};
		};

		"${optionalString (elem release [ "24.11" "25.05" "25.11" ]) release}" = {
			programs.alacritty.settings = {
				shell.program = mkDefault "${pkgs.bashInteractive}/bin/bash";
			};
		};
	}."${release}"
])
