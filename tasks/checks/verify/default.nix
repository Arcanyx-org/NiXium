{ ... }:

# POLICY: non-fatal failures on NixOS with releases OTHER-THAN stable are to be ignored, stable always actionable.

{
	perSystem = { inputs', pkgs, ... }: {
		mission-control.scripts = {
			verify = { # No argument || [DISTRO] [SYSTEM] (RELEASE)
				description = "Verify the system declaration per distribution and release or current if no argument is provided";
				category = "Checks";

				exec = pkgs.writeShellApplication {
					name = "tasks-verify";

					runtimeInputs = [
						pkgs.git
						pkgs.gnused
						pkgs.nixos-rebuild
						pkgs.nixos-install-tools
					];

					text = builtins.readFile ./tasks-verify.sh;
				};
			};
		};
	};
}
