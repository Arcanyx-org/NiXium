{ ... }:

# The DEPLOY Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"deploy" = {
				description = "Deploy the configuration to all systems or specified";
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
					text = builtins.readFile ./tasks-deploy.sh;
				};
			};
		};
	};
}
