{
	... }:

# The TREE Task

let
	inherit (builtins) readFile;
in
{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"tree" = {
				description = "Process the file hierarchy and output user-friendly summary of it";
				category = "docs";

				exec = pkgs.writeShellApplication {
					name = "tasks-tree";

					runtimeInputs = [];

					text = readFile ./tasks-tree.sh;
				};
			};
		};
	};
}
