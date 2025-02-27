{ ... }:

# The BUILD Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"build" = {
				description = "Build and cache the system configuration without deployment";
				category = "Administration";

				exec = pkgs.writeShellApplication {
					name = "tasks-build";

					runtimeInputs = [
						pkgs.nixos-install-tools
						pkgs.nixos-rebuild
						pkgs.gnused
						pkgs.git
					];

					# FIXME(Krey): This should use flake-root to set absolute path
					text = builtins.readFile ./tasks-build.sh;
				};
			};
		};
	};
}
