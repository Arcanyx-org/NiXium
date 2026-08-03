{ lib, self, ... }:

###! # Home Module for Nushell (kreyren)
###!
###! Kreyren's Nushell configuration (extra config, starship integration).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-shells-nushell-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.nushell.enable, enabled here via
###! homeManagerConfig so it activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.shells-nushell-kreyren = ./nushell.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-shells-nushell-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/shells/nushell";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.shells-nushell-kreyren ];
					homeManagerConfig = {
						programs.nushell.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-shells-nushell-kreyren-vm" = vm.vm;
				apps."nixos-home-shells-nushell-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-shells-nushell-kreyren-vm";
				};
			};
	}
]
