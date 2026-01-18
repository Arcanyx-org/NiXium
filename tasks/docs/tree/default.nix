{ ... }:

# The TREE Task

{
	perSystem = { pkgs, ... }: {
		mission-control.scripts = {
			"tree" = {
				description = "Process the file hierarchy and output user-friendly summary of it";
				category = "docs";

				exec = pkgs.writeShellApplication {
					name = "tasks-tree";

					runtimeInputs = [];

					# FIXME(Krey): This should use flake-root to set absolute path
					text = builtins.readFile ./tasks-tree.sh;
				};
			};
		};
	};
}
