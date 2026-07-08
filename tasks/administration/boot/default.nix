{ ... }:

# The BOOT Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"boot" = {
				description = "Boot into the system configuration (nixos-rebuild boot)";
				category = "Administration";

				exec = pkgs.writeShellApplication {
					name = "tasks-boot";

				runtimeInputs = [
					pkgs.nixos-install-tools
					pkgs.openssh
					pkgs.nixos-rebuild
					pkgs.gnused
					pkgs.git
				];

					text = builtins.readFile ./tasks-boot.sh;
				};
			};
		};
	};
}
