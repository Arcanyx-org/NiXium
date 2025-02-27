{ config, pkgs, lib, ... }:

let
	inherit (lib) mkIf mkForce;
in {
	age.secrets.kira-user-password.file = ./kira-user-password.age;

	users.users.kira = {
		description = "Veloraptor";
		uid = 1001;
		isNormalUser = true;
		hashedPasswordFile = config.age.secrets.kira-user-password.path;
		extraGroups = [
			"wheel"
			(mkIf config.virtualisation.docker.enable "docker")
			"dialout" # To Access e.g. /dev/ttyUSB0 for USB debuggers
			(mkIf config.programs.adb.enable "adbusers")
		];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDWzJOwfuNEniLzxeQJxa9Ys+zna4U0SVh7dw1VYN3A" ];
	};

	nix.settings.trusted-users = [ "kira" ]; # Add Kira in Trusted-Users
}
