{ lib, self, ... }:

###! # Home Module for GPG Agent (kreyren)
###!
###! Kreyren's GPG agent setup (SSH support for public-key auth).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-tools-gpg-agent-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###!
###! The module is gated on services.gpg-agent.enable, enabled here via
###! homeManagerConfig so it activates.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.tools-gpg-agent-kreyren = ./gpg-agent.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-tools-gpg-agent-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/tools/gpg-agent";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.tools-gpg-agent-kreyren ];
					homeManagerConfig = {
						services.gpg-agent.enable = true;
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-tools-gpg-agent-kreyren-vm" = vm.vm;
				apps."nixos-home-tools-gpg-agent-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-tools-gpg-agent-kreyren-vm";
				};
			};
	}
]
