{ ... }:

# The SWITCH Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"switch" = {
				description = "Switch the configuration on the current supported system or specified";
				category = "Administration";

				exec = pkgs.writeShellApplication {
					name = "tasks-switch";

					runtimeInputs = [
						pkgs.nixos-install-tools
						pkgs.openssh
						pkgs.nixos-rebuild
						pkgs.gnused
						pkgs.git
					];

					text = builtins.readFile ./tasks-switch.sh;
				};
			};
		};
	};
}
