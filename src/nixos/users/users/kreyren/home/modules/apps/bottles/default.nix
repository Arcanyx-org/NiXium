{ lib, self, ... }:

###! # Home Module for Bottles (kreyren)
###!
###! Kreyren's Bottles configuration: dconf settings for the Bottles app
###! (auto-close, release-candidate, sandbox experiments, steam-proton-support).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-apps-bottles-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! NOTE: the dconf settings only take effect when Bottles is running, which
###! the VM does not exercise — this validates that the module evaluates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.apps-bottles-kreyren = ./bottles.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-apps-bottles-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/apps/bottles";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.apps-bottles-kreyren ];
					homeManagerConfig = { };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-apps-bottles-kreyren-vm" = vm.vm;
				apps."nixos-home-apps-bottles-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-apps-bottles-kreyren-vm";
				};
			};
	}
]
