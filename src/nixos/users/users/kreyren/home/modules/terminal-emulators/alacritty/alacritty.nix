{ lib, pkgs, ... }:

# Common configuration of Alacritty

let
	inherit (lib) mkDefault;
in {
	programs.alacritty = {
		settings = {
			# FIXME-BACKWARDS_COMPAT(Krey): During 24.05 this was using only `shell.*`, but starting 24.11 it's using `terminal.shell.*`
			terminal.shell = {
				program = mkDefault "${pkgs.bashInteractive}/bin/bash";
			};

			keyboard.bindings = [
					{	mods = "Control"; key = "Plus"; action = "IncreaseFontSize"; }
					{	mods = "Control"; key = "Minus"; action = "DecreaseFontSize"; }
					{	mods = "Control"; key = "Equals"; action = "ResetFontSize"; }
			];
		};
	};
}
