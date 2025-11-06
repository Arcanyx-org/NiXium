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
#!
#! ## "WebDAV interface seems broken" error
#! ```
#! Your web server is not yet properly set up to allow file synchronization, because the WebDAV interface seems to be broken. To allow this check to run you have to make sure that your Web server can connect to itself. Therefore it must be able to resolve and connect to at least one of its `trusted_domains` or the `overwrite.cli.url`. This failure may be the result of a server-side DNS mismatch or outbound firewall rule.
#! ```
#!
#! <Fill the info here>

# FIXME(Krey): Implement our own CA for HTTPS

# Config options: https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html

# FIXME(Krey): Setup off-site backup
	# Option 1: Amazon S3: https://aws.amazon.com/s3/pricing, refer to https://wiki.nixos.org/wiki/Nextcloud#Object_store
	# Option 2: Linode https://www.linode.com/pricing/#object-storage

# FIXME-PQ(Krey): Figure out Post Quantum
	# https://github.com/Muzosh/PQC-nextcloud-docker/blob/main/Dockerfile

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkForce mkIf mkMerge;

	domainName = "nextcloud.nx";
in mkIf config.services.nextcloud.enable (mkMerge [
	{
		# Secrets
			age.secrets.mracek-nextcloud-admin-pw = {
				file = "${self.outPath}/src/nixos/machines/mracek/secrets/mracek-nextcloud-admin-pw.age";

				owner = "nextcloud";
				group = "nextcloud";

				symlink = true;
			};

		# Generic
			services.nextcloud.hostName = domainName;
			services.nextcloud.settings.trusted_domains = [	"localhost" domainName "evujb47cvfvxn2eyhiesnycifuu2jwsmwlnq7akgmfesueuuiicfcoad.onion" ];
			services.nextcloud.enableImagemagick = true;
			services.nextcloud.appstoreEnable = true;
			services.nextcloud.configureRedis = true;

		# Database Management
			# Upstream recommends MariaDB/MySQL over SQLite as it's faster and doen't struggle with multiple users
			# NOTE(Krey): mysql and pgsql fails to deploy, using sqlite instead for now
			services.nextcloud.config.dbtype = "pgsql";
			services.nextcloud.database.createLocally = true;

		# Configuration
			services.nextcloud.settings = {
				maintenance_window_start = 1; # Run resource intensive tasks from 01:00 to 05:00

				connectivity_check_domains = [
						"fsfeorg3hsfyuhmdylxrqdvgsmjeoxuuug5a4dv3c3grkxzsl33d3xyd.onion" # FSFE.org
						"2gzyxa5ihm7nsggfxnu52rck2vv4rvmdlkiu3zzui5du4xyclen53wid.onion" # torproject.org
				];

				enabledPreviewProviders = [
					"OC\\Preview\\BMP"
					"OC\\Preview\\GIF"
					"OC\\Preview\\JPEG"
					"OC\\Preview\\Krita"
					"OC\\Preview\\MarkDown"
					"OC\\Preview\\MP3"
					"OC\\Preview\\OpenDocument"
					"OC\\Preview\\PNG"
					"OC\\Preview\\TXT"
					"OC\\Preview\\XBitmap"
					"OC\\Preview\\HEIC"
					"OC\\Preview\\Movie"
				];

				# FIXME-UPSTREAM(Krey): This should be set by default, cuz Nix manages this for us
					updatechecker = false;
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
			services.nextcloud.https = true;
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

				# Add these security headers (server block). 'always' makes sure headers are added even for 4xx/5xx and proxied/fastcgi responses.
				extraConfig = concatStringsSep "\n" [
					# XSS protection (addresses the Nextcloud warning)
					"add_header X-XSS-Protection \"1; mode=block\" always;"

					# Recommended companion headers (optional but good hygiene)
					"add_header X-Content-Type-Options \"nosniff\" always;"
					"add_header X-Frame-Options \"SAMEORIGIN\" always;"
					"add_header Referrer-Policy \"no-referrer-when-downgrade\" always;"
					"add_header Permissions-Policy \"interest-cohort=()\" always;"
				];
			};

		# Apps
			# Review https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/servers/nextcloud/packages/nextcloud-apps.json for default options
			services.nextcloud.extraAppsEnable = true; # Enable Apps
			services.nextcloud.autoUpdateApps.enable = true;
			services.nextcloud.autoUpdateApps.startAt = "05:00:00";
			services.nextcloud.extraApps = with config.services.nextcloud.package.packages.apps; { inherit
				# FIXME(Krey): Add assistant
				# FIXME(Krey): Add welcome
				# FIXME(Krey): Add integration_mastodon
				# FIXME(Krey): Add terms_of_service
				# FIXME(Krey): Add passwords
				# FIXME(Krey): Add twofactor_totp
				# FIXME(Krey): Add spreed
					calendar
					contacts
					end_to_end_encryption
					maps
					music
					news
					tasks
					richdocuments
					notify_push
					cospend;
			};

		# Integrity Checks
			services.nextcloud.settings.integrity.check.disabled = false; # Re-Enable integrity checks which are disabled by nixpkgs for some reason

		# The Onion Service
			services.tor.relay.onionServices."nextcloud".map = mkIf config.services.tor.enable [ 443 ];

			# Import the private key for an onion service
				age.secrets.mracek-onion-nextcloud-private = {
					file = ../secrets/mracek-onion-nextcloud-private.age;

					owner = "tor";
					group = "tor";

					path = "/var/lib/tor/onion/nextcloud/hs_ed25519_secret_key";

					symlink = false; # Appears to not work as symlink
				};

		# Make sure that all traffic from nextcloud is torrified
			services.nextcloud.settings.trusted_proxies = [	"127.0.0.1" ]; # Set Tor as trusted proxy
			services.nextcloud.settings.proxy = "socks5h://127.0.0.1:9050";

			# DNS Pinning neds to be disabled to prevent the service from trying to reach system DNS to resolve onion links (https://github.com/nextcloud/server/issues/55847#issuecomment-3423021848)
				services.nextcloud.settings.dns_pinning = false;

		# OPcache - Mandated by Nextcloud (https://docs.nextcloud.com/server/31/admin_manual/installation/server_tuning.html#enable-php-opcache)
			services.nextcloud.phpOptions."opcache.interned_strings_buffer" = toString 23;
			services.nextcloud.phpOptions."opcache.memory_consumption" = toString 128;
			services.nextcloud.phpOptions."opcache.max_accelerated_files" = toString 10000;

		# Notify Push
			# FIXME(Krey): Figure out how to make it work
			# FIXME-UPSTREAM(Krey): `There are no commands defined in the "notify_push" namespace` when `notify_push` is not added as an app
				services.nextcloud.notify_push.enable = false;
			# services.nextcloud.notify_push.bendDomainToLocalhost = true;
			# services.nextcloud.notify_push.nextcloudUrl = "https://nextcloud.nx";
			# services.nextcloud.secretFile = "${pkgs.writeText "test" ''{"redis":{"password":"insecure"}}''}";
			# systemd.services."nextcloud-notify_push".environment = {
			# 	ALL_PROXY = "127.0.0.1:9050";
			# };
			# systemd.services."nextcloud-notify_push_setup".environment = {
			# 	ALL_PROXY = "127.0.0.1:9050";
			# };
			# systemd.services."nextcloud-notify_push_setup".serviceConfig.Environment = concatStringsSep "\n" [
			# 	"http_proxy=socks5h://127.0.0.1:9050"
			# 	"https_proxy=socks5h://127.0.0.1:9050"
			# ];
			# FIXME-UPSTREAM(Krey): This is a nixpkgs bug as there is no way to configure notify_push to use --allow-self-signed in this scenario
				# systemd.services.nextcloud-notify_push = {
				# 	serviceConfig = {
				# 		Environment = concatStringsSep "\n" [
				# 			"DATABASE_URL=postgresql://nextcloud/nextcloud?host=/run/postgresql"
				# 		];

				# 		ExecStart = mkForce "${pkgs.nextcloud-notify_push}/bin/notify_push --allow-self-signed /var/lib/nextcloud/config/config.php";
				# 	};
				# };

		# Impermanence
			environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
				# { directory = "${config.services.nextcloud.home}"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
				# { directory = "/var/lib/redis-nextcloud"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
				# (mkIf (config.services.nextcloud.config.dbtype == "pgsql") { directory = "/var/lib/postgresql"; user = "postgres"; group = "postgres"; mode = "u=rwx,g=rx,o="; })

				# { directory = "${config.services.nextcloud.home}/config"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }

				# FIXME-QA(Krey): This shouldn't be here, but if we set the kreyren persist below it creates data directory with root:root ownership
					# { directory = "${config.services.nextcloud.home}/data"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
				# { directory = "${config.services.nextcloud.home}/data/kreyren"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
			];
	}
])
