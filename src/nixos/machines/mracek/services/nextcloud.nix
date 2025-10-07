{ self, config, lib, pkgs, ... }:

# Mracek-specific management of nextcloud

# Config options: https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html

# FIXME(Krey): Setup off-site backup
	# Option 1: Amazon S3: https://aws.amazon.com/s3/pricing, refer to https://wiki.nixos.org/wiki/Nextcloud#Object_store
	# Option 2: Linode https://www.linode.com/pricing/#object-storage

let
	inherit (lib) mkIf;

	domainName = "nextcloud.nx";
in mkIf config.services.nextcloud.enable {
	# Secrets

	# Generic
		services.nextcloud.hostName = domainName;
		services.nextcloud.settings.trusted_domains = [ domainName ];

	# Database Management
		# Upstream recommends MariaDB/MySQL over SQLite as it's faster and doen't struggle with multiple users
		# NOTE(Krey): mysql and pgsql fails to deploy, using sqlite instead for now
		services.nextcloud.config.dbtype = "mysql";
		# services.nextcloud.database.createLocally = true;
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
		services.nextcloud.https = false;
		security.acme.certs = mkIf config.services.nextcloud.https {
			"${domainName}" = {};
		};

	# Apps
		# Review https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/servers/nextcloud/packages/nextcloud-apps.json for default options
		services.nextcloud.extraAppsEnable = true; # Enable Apps
		services.nextcloud.extraApps = with config.services.nextcloud.package.packages.apps; {
			inherit end_to_end_encryption;
		};

	# The Onion Service
		services.tor.relay.onionServices."nextcloud" = {
			map = mkIf config.services.tor.enable [{
				target = { port = 80; };
				port = 80;
			}];
		};

		# Import the private key for an onion service
			# age.secrets.mracek-onion-nextcloud-private = {
			# 	file = ../secrets/mracek-onion-nextcloud-private.age;

			# 	owner = "tor";
			# 	group = "tor";

			# 	path = "/var/lib/tor/onion/nextcloud/hs_ed25519_secret_key";

			# 	symlink = false; # Appears to not work as symlink
			# };

	# Impermanence
		environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
			{ directory = config.services.nextcloud.home; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		];
}
