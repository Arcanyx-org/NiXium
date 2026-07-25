{ ... }:

# The KEXEC Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"kexec" = {
				description = "Kexec into a new system configuration without rebooting (preserves LUKS, speeds up dev)";
				category = "Administration";

				exec = pkgs.writeShellApplication {
					name = "tasks-kexec";

					runtimeInputs = [
						pkgs.nixos-install-tools
						pkgs.openssh
						pkgs.nixos-rebuild
						pkgs.gnused
						pkgs.git
					];

					text = builtins.readFile ./tasks-kexec.sh;
				};
			};
		};
	};
}