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

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkForce mkIf;

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
		services.nextcloud.settings.trusted_domains = [	domainName "localhost" ];
		services.nextcloud.enableImagemagick = true;
		services.nextcloud.appstoreEnable = true;

	# Database Management
		# Upstream recommends MariaDB/MySQL over SQLite as it's faster and doen't struggle with multiple users
		# NOTE(Krey): mysql and pgsql fails to deploy, using sqlite instead for now
		services.nextcloud.config.dbtype = "pgsql";
		services.nextcloud.database.createLocally = true;

	# Configuration
		services.nextcloud.settings = {
			# Set Proxy
				# proxy = "127.0.0.1:9050"; # Use Tor

			# This disables Nextcloud's periodic external site connectivity checks
				connectivity_check_domains = [
					"fsfeorg3hsfyuhmdylxrqdvgsmjeoxuuug5a4dv3c3grkxzsl33d3xyd.onion" # FSFE.org
					"2gzyxa5ihm7nsggfxnu52rck2vv4rvmdlkiu3zzui5du4xyclen53wid.onion" # torproject.org
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
			inherit calendar contacts end_to_end_encryption maps music news tasks richdocuments spreed notify_push cospend;
		};

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
		# FIXME-UPSTREAM(Krey): This will not work as Nextcloud lacks implementation for socks5h proxy.. Pending request upstream
			# systemd.services."phpfpm-nextcloud".serviceConfig.ExecStartPre = [
			# 	"${pkgs.torsocks}/bin/torsocks true"
			# ];
			# services.nextcloud.settings.proxy = "127.0.0.1:9050";
		services.tor.settings.HTTPTunnelPort = 8118;
		services.nextcloud.settings.proxy = "127.0.0.1:8118";
		# systemd.services.phpfpm-nextcloud.serviceConfig.Environment = concatStringsSep "\n" [
		# 	"http_proxy='socks5h://127.0.0.1:9050'"
		# 	"https_proxy='socks5h://127.0.0.1:9050'"
		# ];

	# Notify Push
		# FIXME(Krey): Figure out how to make it work
		services.nextcloud.notify_push.enable = true;
		# services.nextcloud.notify_push.bendDomainToLocalhost = true;
		# services.nextcloud.notify_push.nextcloudUrl = "https://localhost";
		# services.nextcloud.secretFile = "${pkgs.writeText "test" ''{"redis":{"password":"insecure"}}''}";
		# systemd.services."nextcloud-notify_push".environment = {
		# 	ALL_PROXY = "127.0.0.1:9050";
		# };
		# systemd.services."nextcloud-notify_push_setup".environment = {
		# 	ALL_PROXY = "127.0.0.1:9050";
		# };
		networking.hosts = {
			"127.0.0.1" = [ config.services.nextcloud.hostName ];
			"::1" = [ config.services.nextcloud.hostName ];
		};
		# systemd.services."nextcloud-notify_push_setup".serviceConfig.Environment = concatStringsSep "\n" [
		# 	"http_proxy=socks5h://127.0.0.1:9050"
		# 	"https_proxy=socks5h://127.0.0.1:9050"
		# ];
		# FIXME-UPSTREAM(Krey): This is a nixpkgs bug as there is no way to configure notify_push to use --allow-self-signed in this scenario
			systemd.services.nextcloud-notify_push = {
				serviceConfig = {
					Environment = concatStringsSep "\n" [
						"DATABASE_URL=postgresql://nextcloud/nextcloud?host=/run/postgresql"
					];

					ExecStart = mkForce "${pkgs.nextcloud-notify_push}/bin/notify_push --allow-self-signed /var/lib/nextcloud/config/config.php";
				};
			};

	# Impermanence
		# environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		# 	{ directory = "${config.services.nextcloud.home}"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		# 	{ directory = "/var/lib/redis-nextcloud"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		# 	(mkIf (config.services.nextcloud.config.dbtype == "pgsql") { directory = "/var/lib/postgresql"; user = "postgres"; group = "postgres"; mode = "u=rwx,g=rx,o="; })
		# ];
}

