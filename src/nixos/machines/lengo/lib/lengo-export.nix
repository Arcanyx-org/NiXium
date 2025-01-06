{ config, lib, ... }:

# Module exporting configuration from LENGO to other systems

let
	inherit (lib) mkIf mkMerge;
in mkMerge [
	{
		# SSHD on Onions
		# age.secrets.lengo-onion = {
		# 	file = ../secrets/lengo-onion.age;

		# 	owner = "tor";
		# 	group = "tor";
		# 	mode = "0400"; # Only read for the user

		# 	# FIXME(Krey): This should be using `config.services.tor.settings.dataDir`, but that results in `error: infinite recursion encountered` so if we ever change the DataDir then that will have to be changed here as well otherwise it will cause issues
		# 	# path = "${config.services.tor.settings.DataDir}/pelagus-onion.conf";
		# 	path = "/var/lib/tor/lengo-onion.conf";

		# 	# FIXME(Krey): has to be without symlink due to bug with link ownership https://github.com/ryantm/agenix/issues/261
		# 	symlink = false;
		# };

		# # Add to the tor settings
		# services.tor.settings."%include" = [
		# 	config.age.secrets."lengo-onion".path
		# ];
	}
]
