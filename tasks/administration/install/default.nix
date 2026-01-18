{ ... }:

# The Install Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"install" = {
				description = "Perform declaration installation on the specified distribution, system and release";
				category = "Administration";

				exec = pkgs.writeShellApplication {
					name = "tasks-install";

					runtimeInputs = [
						pkgs.nixos-install-tools
						pkgs.nixos-rebuild
						pkgs.gnused
						pkgs.git
					];

					# FIXME(Krey): This should use flake-root to set absolute path
					text = builtins.readFile ./tasks-install.sh;
				};
			};
		};
	};
}
