{ lib, self, ... }:

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in {
	imports = [
		./themes
	];

	config = mkMerge [
		{
			flake.homeManagerModules.ui-gnome-kira.imports = [
				./config/input.nix
				./config/nightlight-filter.nix
				./config/shortcuts.nix
				./config/touchpad.nix
				./config/usability.nix
				./config/weather.nix
			];
		}

		{
			perSystem = { system, pkgs, ... }:
				let
					vm = mkVM {
						inherit pkgs system;
						name = "home-ui-gnome-kira-vm";
						command = "bash";
						modulePath = "$FLAKE_ROOT/src/nixos/users/users/kira/home/modules/user-interface/gnome";
						graphical = "wayland";
						homeManagerModules = [ self.homeManagerModules.ui-gnome-kira ];
						homeManagerConfig = { };
						user = "kira";
						userConfig = { description = "Kira"; };
						exitMode = "shell";
						timeout = null;
						networking = true;
					};
				in {
					packages."nixos-home-ui-gnome-kira-vm" = vm.vm;
					apps."nixos-home-ui-gnome-kira-vm" = {
						type = "app";
						program = "${vm.runner}/bin/nixos-home-ui-gnome-kira-vm";
					};
				};
		}
	];
}
