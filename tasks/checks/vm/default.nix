{ ... }:

# The VM Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"vm" = {
				description = "Open the derivation in a Virtual Machine";
				category = "Checks";

				exec = pkgs.writeShellApplication {
					name = "tasks-wm";

					runtimeInputs = [
						pkgs.nixos-install-tools
						pkgs.nixos-rebuild
						pkgs.gnused
						pkgs.git
					];

					# FIXME(Krey): This should use flake-root to set absolute path
					text = builtins.readFile ./tasks-vm.sh;
				};
			};
		};
	};
}
