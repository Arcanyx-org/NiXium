{ lib, self, ... }:

# FIXME-VM(Krey): This is currently not possible to test in VM as we are not handling ragenix secrets to get the auth on the system

let
	inherit (lib) mkMerge;
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.apps-opencode-kreyren = ./opencode.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let
				vm = mkVM {
					inherit pkgs system;
					name = "apps-opencode-kreyren";
					command = "opencode";
					modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/apps/opencode";
					graphical = "wayland";
					homeManagerModules = [
						self.homeManagerModules.apps-opencode-kreyren
						# FIXME(Krey): This should be handled internally by mkVM to avoid repetition in every VM module
						self.inputs.ragenix.homeManagerModules.default
					];
					homeManagerConfig = {
						home.packages = [ pkgs.opencode ];
					};
					user = "kreyren";
					userConfig = { description = "Kreyren"; };
				};
			in {
				packages."nixos-vm-apps-opencode-kreyren" = vm.vm;
				apps."nixos-vm-apps-opencode-kreyren" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-vm-apps-opencode-kreyren";
				};
			};
	}
]
