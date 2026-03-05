{ ... }:

# The SHELLCHECK Task

let
	inherit (builtins) readFile;
in
{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"shellcheck" = {
				description = "Run shellcheck on all shell scripts in the repository";
				category = "Checks";

				exec = pkgs.writeShellApplication {
					name = "tasks-shellcheck";

					runtimeInputs = [ pkgs.shellcheck ];

					text = readFile ./tasks-shellcheck.sh;
				};
			};
		};
	};
}
