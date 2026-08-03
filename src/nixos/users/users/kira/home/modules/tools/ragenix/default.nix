{ lib, self, ... }:

###! # Home Module for ragenix (kira)
###!
###! Sets kira's age identity path for secret decryption, switching between the
###! persistent path (impermanence) and the default home path.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-ragenix-kira-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! NOTE: age secrets are NOT decrypted in the VM (no identity available) —
###! only the identityPaths declaration is exercised.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-ragenix-kira = ./ragenix.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-ragenix-kira-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/tools/ragenix";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.tools-ragenix-kira
						# Module sets age.identityPaths — declared by ragenix HM module.
						self.inputs.ragenix.homeManagerModules.default
					];
					homeManagerConfig = { };
					user = "kira";
					userConfig = { description = "Kira"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-ragenix-kira-vm" = vm.vm;
				apps."nixos-home-tools-ragenix-kira-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-ragenix-kira-vm";
				};
			};
	}
]
