{ self, config, lib, ... }:

let
	inherit (lib) mkIf versionOlder;
	inherit (lib.trivial) release;
in {
	users.users.tester = {
		description = "Tester";
		uid = 1024;
		isNormalUser = true;
		createHome = true;
		password = "000000";
		extraGroups = [
			"disk"
			(mkIf config.virtualisation.docker.enable "docker")
			"dialout" # To Access e.g. /dev/ttyUSB0 for USB debuggers
			(mkIf config.programs.gamemode.enable "gamemode")
			"video"
		] ++ lib.optional (versionOlder release "26.05" && config.programs.adb.enable) "adbusers";
		# openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" ];
	};


	nix.settings.trusted-users = [ "tester" ]; # Add Kreyren in Trusted-Users
}
