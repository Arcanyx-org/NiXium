{ self, config, lib, pkgs, ... }:

# Mracek-specific management of nextcloud

# Config options: https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html

# FIXME(Krey): Setup off-site backup
	# Option 1: Amazon S3: https://aws.amazon.com/s3/pricing, refer to https://wiki.nixos.org/wiki/Nextcloud#Object_store
	# Option 2: Linode https://www.linode.com/pricing/#object-storage

let
	inherit (lib) mkIf;
in mkIf config.services.nextcloud.enable {
	# Secrets


	# Generic
		services.nextclud.hostName = "nextcloud.nx";
		services.nextcloud.settings.trusted_domains = [ "nextcloud.nx" ];

	# Database Management
		services.nextcloud.database.createLocally = false; # Use password-based database instead of socket
		# services.nextcloud.config = {
		# 	dbname = "nextcloud";
		# 	dbtype = "sqlite";

		# 	dbhost = "localhost:5000";

		# 	dbuser = "nextcloud";
		# 	dbpassFile = "${pkgs.writeText "nextcloud_db.key" "000000"}";
		# };

	# User Management
		# Administrator
		services.nextcloud.config = {
			adminuser = "kreyren";
			adminpassFile = "${pkgs.writeText "nextcloud_nextcloud_pw.key" "000000"}";
		};
		# FIXME(Krey): Requires 3rd party module, to be checked..
		# services.nextcloud.ensureUsers = {
		# 	kreyren = {
		# 		email = "kreyren@fsfe.org";
		# 		# DNM(Krey): Just for testing
		# 		passwordFile = "${pkgs.writeText "kreyren_nextcloud_pw.key" "000000"}";
		# 	};
		# };

	# HTTPS
		# FIXME(Krey): Turn on HTTPS including self-signed cert
		services.nextcloud.https = false;

	networking.firewall = {
		allowedTCPPorts = [ 80 ];
		# allowedUDPPorts = [ 9757 ];
	};

	# Apps
		# Review https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/servers/nextcloud/packages/nextcloud-apps.json for default options
		services.nextcloud.extraAppsEnable = true; # Enable Apps
		services.nextcloud.extraApps = with config.services.nextcloud.package.packages.apps; {
			inherit end_to_end_encryption;
		};

	# Import the private key for an onion service
		# age.secrets.mracek-onion-nextcloud-private = {
		# 	file = ../secrets/mracek-onion-nextcloud-private.age;

		# 	owner = "tor";
		# 	group = "tor";

		# 	path = "/var/lib/tor/onion/nextcloud/hs_ed25519_secret_key";

		# 	symlink = false; # Appears to not work as symlink
		# };

		# services.tor.relay.onionServices."nextcloud" = mkIf config.services.tor.enable {
		# 	# NOTE(Krey): It's declared this way so that we don't have to use `url.onion:3000` as the web browsers will default to using port 80 for HTTP and port 443 for HTTPS
		# 	map = [{ port = 80; target = { port = config.services.gitea.settings.server.HTTP_PORT; }; }]; # Set up Onionized Gitea
		# };

	# Impermanence
		environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
			{ directory = config.services.nextcloud.home; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		];
}
