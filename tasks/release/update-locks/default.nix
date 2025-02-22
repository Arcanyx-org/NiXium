{ ... }:

{
	perSystem = { inputs', pkgs, lib, ... }: {
		mission-control.scripts = {
			"update-locks" = {
				description = "Update the flake locks";
				category = "Release Management";
				exec = "nix flake update --verbose";
			};
		};
	};
}
