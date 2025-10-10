{ self, config, lib, pkgs, ... }:

#! # Nextcloud Management of MRACEK
#!
#! ## SSL
#! Using self-signed certificate over onions generated via:
#! ```sh
#! $ openssl req -x509 -newkey rsa:4096 -keyout mracek-nextcloud-ssl-cert.key -out mracek-nextcloud-ssl-cert.crt \
#!  -days 3650 -nodes -subj "/CN=nextcloud.nx" \
#!  -addext "basicConstraints=CA:FALSE" \
#! -addext "keyUsage = digitalSignature, keyEncipherment" \
#!  -addext "extendedKeyUsage = serverAuth"
#! ```
#!
#! This is needed to avoid `MOZILLA_PKIX_ERROR_CA_CERT_USED_AS_END_ENTITY` in Firefox as this makes it an end-entity cert, and Firefox will accept it as long as it’s trusted (either via ImportEnterpriseRoots or installed manually).

# FIXME(Krey): Implement our own CA for HTTPS

# Config options: https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html

# FIXME(Krey): Setup off-site backup
	# Option 1: Amazon S3: https://aws.amazon.com/s3/pricing, refer to https://wiki.nixos.org/wiki/Nextcloud#Object_store
	# Option 2: Linode https://www.linode.com/pricing/#object-storage

# FIXME-SECURITY(Krey): Figure out Post Quantum

let
	inherit (lib) mkIf;

	domainName = "nextcloud.nx";
in mkIf config.services.nextcloud.enable {
	# Secrets
		age.secrets.mracek-nextcloud-admin-pw = {
			file = "${self.outPath}/src/nixos/machines/mracek/secrets/mracek-nextcloud-admin-pw.age";

			owner = "nextcloud";
			group = "nextcloud";

			symlink = true;
		};

	# Generic
		services.nextcloud.hostName = domainName;
		services.nextcloud.settings.trusted_domains = [ domainName ];
		services.nextcloud.enableImagemagick = true;
		services.nextcloud.appstoreEnable = true;

	# Database Management
		# Upstream recommends MariaDB/MySQL over SQLite as it's faster and doen't struggle with multiple users
		# NOTE(Krey): mysql and pgsql fails to deploy, using sqlite instead for now
		services.nextcloud.config.dbtype = "sqlite";
		services.nextcloud.database.createLocally = true;

	# Configuration
		services.nextcloud.settings = {
			# Set Proxy
				proxy = "127.0.0.1:9050"; # Use Tor
		};
		services.nextcloud.config = {
			# Set Administrator Account
				adminuser = "kreyren";
				adminpassFile = config.age.secrets.mracek-nextcloud-admin-pw.path;
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
		age.secrets.mracek-nextcloud-ssl-cert = {
			file = "${self.outPath}/src/nixos/machines/mracek/secrets/mracek-nextcloud-ssl-cert.age";
			path = "/var/lib/nextcloud/mracek-nextcloud-ssl-cert.key";

			owner = "nginx";
			group = "nginx";

			symlink = false;
		};
		services.nginx.virtualHosts."${domainName}" = {
			forceSSL = true;
			enableACME = false; # Disable ACME since we use self-signed and ACME won't let us sign NX TLD
			sslCertificate = "${"${self.outPath}/src/nixos/machines/mracek/certificates/mracek-nextcloud-ssl-cert.crt"}";
			sslCertificateKey = config.age.secrets.mracek-nextcloud-ssl-cert.path;
			listen = [{
				addr = "127.0.0.1";
				port = 443;
				ssl = true;
			}];
		};

	# Apps
		# Review https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/servers/nextcloud/packages/nextcloud-apps.json for default options
		services.nextcloud.extraAppsEnable = true; # Enable Apps
		services.nextcloud.autoUpdateApps.enable = true;
		services.nextcloud.autoUpdateApps.startAt = "05:00:00";
		services.nextcloud.extraApps = with config.services.nextcloud.package.packages.apps; {
			# FIXME(Krey): Add assistant
			# FIXME(Krey): Add welcome
			# FIXME(Krey): Add integration_mastodon
			# FIXME(Krey): Add terms_of_service
			# FIXME(Krey): Add passwords
			# FIXME(Krey): Add twofactor_totp
			inherit calendar end_to_end_encryption maps music tasks richdocuments spreed;
		};

	# The Onion Service
		services.tor.relay.onionServices."nextcloud".map = mkIf config.services.tor.enable [
			80 # HTTP
			443 # HTTPS
		];

		# Import the private key for an onion service
			age.secrets.mracek-onion-nextcloud-private = {
				file = ../secrets/mracek-onion-nextcloud-private.age;

				owner = "tor";
				group = "tor";

				path = "/var/lib/tor/onion/nextcloud/hs_ed25519_secret_key";

				symlink = false; # Appears to not work as symlink
			};

	# Notify Push
	services.nextcloud.notify_push.enable = false;

	# Impermanence
		environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
			{ directory = "${config.services.nextcloud.home}"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		];
}
