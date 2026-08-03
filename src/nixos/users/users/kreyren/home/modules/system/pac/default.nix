{ lib, self, ... }:

###! # Home Module for PAC Proxy (kreyren)
###!
###! Kreyren's Proxy Automatic Configuration: installs proxy.pac and configures
###! GNOME to use it (release-gated for the desktopManager.gnome option rename).
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###!
###! Usage:
###!   nix run .#nixos-home-system-pac-kreyren-vm
###!
###! The VM will boot into a bash shell via: greetd -> cage -> foot.
###! The GNOME dconf part is gated on the system GNOME option — not enabled in
###! the VM, so only the proxy.pac file installation is exercised.

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.system-pac-kreyren = ./pac.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "home-system-pac-kreyren-vm";
					command = "bash";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/system/pac";
					graphical = "wayland";
					homeManagerModules = [ self.homeManagerModules.system-pac-kreyren ];
					homeManagerConfig = { };
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
					exitMode = "shell";
					timeout = null;
					networking = true;
				};
			in {
				packages."nixos-home-system-pac-kreyren-vm" = vm.vm;
				apps."nixos-home-system-pac-kreyren-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-home-system-pac-kreyren-vm";
				};
			};
	}
]
