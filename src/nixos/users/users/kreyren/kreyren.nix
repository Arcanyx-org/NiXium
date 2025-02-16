{ config, lib, ... }:

### SUPER ADMINISTRATOR ###

# Module that is going to set up the KREYREN user

let
	inherit (lib) mkIf mkForce;
in {
	age.secrets.kreyren-user-password.file = ./kreyren-user-password.age;
	# sops.secrets."users/kreyren/hashed-password".neededForUsers = true;

	users.users.kreyren = {
		description = "Raptor"; # FIXME(Krey): Figure out how to handle this
		uid = 1000;
		isNormalUser = true;
		createHome = true;
		hashedPasswordFile = config.age.secrets.kreyren-user-password.path;
		# hashedPasswordFile = config.sops.secrets."users/kreyren/hashed-password".path;
		extraGroups = [
			"wheel"
			(mkIf config.virtualisation.docker.enable "docker")
			"dialout" # To Access e.g. /dev/ttyUSB0 for USB debuggers
			(mkIf config.programs.adb.enable "adbusers")
		];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" ];
	};

	users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" ]; # Allow root access for all systems for kreyren

	nix.settings.trusted-users = [ "kreyren" ]; # Add Kreyren in Trusted-Users

	# Set Password for Virtual Machine Checks
	virtualisation.vmVariantWithDisko.users.users.kreyren = {
		hashedPasswordFile = mkForce null;
		password = "a"; # Fastest to brute force password
	};
}
