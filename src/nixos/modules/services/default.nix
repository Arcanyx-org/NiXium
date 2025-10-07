{ config, lib, ... }:

# Global Service Management

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.services.imports = [
		nixosModules.services-distributedBuilds
		nixosModules.services-monero
		nixosModules.services-opensnitch
		nixosModules.services-sshd
		nixosModules.services-tor
	];

	imports = [
		./distributedBuilds
		./monero
		./opensnitch
		./sshd
		./tor
	];
}
