{ ... }:

{
	perSystem = { inputs', ... }: {
		mission-control.scripts = {
			"rekey" = {
				description = "Re-Key All Ragenix Keys";
				category = "Secrets Management";
				exec = ''
					# NixOS
					RULES="$FLAKE_ROOT/src/nixos/secrets.nix" ${inputs'.ragenix.packages.ragenix}/bin/ragenix --rekey
				'';
			};
		};
	};
}
