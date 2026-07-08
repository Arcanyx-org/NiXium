{ config, lib, ... }:

# Global Security Management

let
	inherit (lib) mkForce;
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.security.imports = [
		nixosModules.security-acme
		nixosModules.security-nvidia
		nixosModules.security-sudo
		nixosModules.security-debugfs

		{
			system.copySystemConfiguration = mkForce false; # Do not copy system configuration as it will be incomplete due to our use of flakes and may contain secrets

			boot.loader.systemd-boot.editor = mkForce false; # Do not allow systemd-boot editor as it's set `true` by default for user convicience and can be used to inject root commands to the system
		}
	];

	imports = [
		./acme
		./nvidia
		./sudo
		./debugfs
	];
}
