{ lib, self, ... }:

###! # Home Module for ragenix (kreyren)
###!
###! Sets kreyren's age identity path for secret decryption, switching between
###! the persistent path (impermanence) and the default home path.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-ragenix-kreyren-vm
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
		flake.homeManagerModules.tools-ragenix-kreyren = ./ragenix.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-ragenix-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/tools/ragenix";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.tools-ragenix-kreyren
						# Module sets age.identityPaths — declared by ragenix HM module.
						self.inputs.ragenix.homeManagerModules.default
					];
					homeManagerConfig = { };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-ragenix-kreyren-vm" = vm.vm;
				apps."nixos-home-tools-ragenix-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-ragenix-kreyren-vm";
				};
			};
	}
]
