{ config, ... }:

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.users.imports = [
		nixosModules.users-kreyren
		nixosModules.users-kira
	];

	imports = [
		./kreyren
		./kira
	];
}
