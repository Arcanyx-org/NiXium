{ lib, self, inputs, ... }:

###! # Home Module for Flatpak
###!
###! Persists flatpak user data when impermanence is enabled and registers the
###! flathub remote at login.
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-flatpak-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-flatpak = ./flatpak.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-flatpak-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/modules/system/flatpak";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.system-flatpak
						# Module references config.home.impermanence.enable —
						# vendored impermanence HM module declares that option.
						self.inputs.impermanence.nixosModules.home-manager.impermanence
					];
					homeManagerConfig = {
						# TODO(Krey): The module is gated on the system option
						# services.flatpak.enable — enable it via systemConfig too.
					};
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-flatpak-vm" = vm.vm;
				apps."nixos-home-system-flatpak-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-flatpak-vm";
				};
			};
	}
]
