{ lib, self, ... }:

###! # Home Module for Bash (kreyren)
###!
###! Kreyren's Bash configuration (completion enabled).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-shells-bash-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on programs.bash.enable, enabled here via
###! homeManagerConfig so it activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.shells-bash-kreyren = ./bash.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-shells-bash-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/shells/bash";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.shells-bash-kreyren ];
					homeManagerConfig = {
						programs.bash.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-shells-bash-kreyren-vm" = vm.vm;
				apps."nixos-home-shells-bash-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-shells-bash-kreyren-vm";
				};
			};
	}
]
