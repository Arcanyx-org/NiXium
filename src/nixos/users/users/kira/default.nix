{
	flake.nixosModules.users-kira = ./kira.nix;

	imports = [ ./home	];
}
