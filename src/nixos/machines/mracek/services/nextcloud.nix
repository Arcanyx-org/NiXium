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
		services.nextcloud.configureRedis = true;

	# Database Management
		# Upstream recommends MariaDB/MySQL over SQLite as it's faster and doen't struggle with multiple users
		# NOTE(Krey): mysql and pgsql fails to deploy, using sqlite instead for now
		services.nextcloud.config.dbtype = "pgsql";
		services.nextcloud.database.createLocally = true;

	# Configuration
		services.nextcloud.settings = {
			maintenance_window_start = 1; # Run resource intensive tasks from 01:00 to 05:00

			# This disables Nextcloud's periodic external site connectivity checks
				connectivity_check_domains = [
					# FIXME(Krey): Gruzzle's refusing to use Tor DNS to resolve those
						# "fsfeorg3hsfyuhmdylxrqdvgsmjeoxuuug5a4dv3c3grkxzsl33d3xyd.onion" # FSFE.org
						# "2gzyxa5ihm7nsggfxnu52rck2vv4rvmdlkiu3zzui5du4xyclen53wid.onion" # torproject.org
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

		# Oh no.. ugh,,, -> Setup DNS Service that uses tor
			# services.tor.settings.DNSPort = 53;
			# networking.nameservers = [ "127.0.0.1" ];

		# Ideal fix
			# [warn] Socks version 80 not recognized. (This port is not an HTTP proxy; did you want to use HTTPTunnelPort?)
			# services.nextcloud.settings.proxy = "127.0.0.1:9050";

		# Ideal fix
			# services.nextcloud.settings.proxy = "socks5h://127.0.0.1:9050";

		# FAIL: Tries to do connection to localhost
			# [warn] Rejecting SOCKS request for anonymous connection to private address [scrubbed].
			# networking.nameservers = [ "127.0.0.1" "::1" ];
			# services.tor.settings.DNSPort = 5353;
			# services.nextcloud.settings.proxy = "socks5h://127.0.0.1:9050";

		# Works, but can't resolve onion URLs
			# services.tor.settings.HTTPTunnelPort = 8118;
			# services.nextcloud.settings.proxy = "127.0.0.1:8118";


		# FAIL: Privoxy won't resolve the hostnames either
			# services.privoxy = {
			# 	enable = true;

			# 	settings = {
			# 		"listen-address" = "127.0.0.1:8118";

			# 		"forward-socks5" = "/ 127.0.0.1:9050 ."; # Forward all HTTP requests
			# 	};
			# };

			# services.nextcloud.settings.proxy = "127.0.0.1:8118";

		# FAIL: Won't get proxied
			# systemd.services."phpfpm-nextcloud".serviceConfig.ExecStartPre = [
			# 	"${pkgs.torsocks}/bin/torsocks on"
			# ];
			# services.nextcloud.settings.proxy = "127.0.0.1:9050";

		# FAIL: Internal server fail
			# systemd.services."phpfpm-nextcloud".serviceConfig.ExecStart = mkForce (concatStringsSep "\n" [
			# 	"${pkgs.torsocks}/bin/torsocks ${config.services.nextcloud.phpPackage}/bin/php-fpm -y	/nix/store/lnb4zvzzb4dgvafsqa38nbzgnx41ra7q-phpfpm-nextcloud.conf -c /nix/store/71ybhix6bsjli10a46554prrfmcam59p-php.ini"
			# 	# ${pkgs.}/nix/store/vy8h6ixnw3rxgj87hfwa8qqwnrj97y9d-php-with-extensions-8.3.26/bin/php-fpm -y /nix/store/lnb4zvzzb4dgvafsqa38nbzgnx41ra7q-phpfpm-nextcloud.conf -c /nix/store/71ybhix6bsjli10a46554prrfmcam59p-php.ini
			# 	# "${pkgs.torsocks}/bin/torsocks on"
			# ]);

		# FAIL: Won't resolve DNS to onion services
			# services.nextcloud.settings.proxy = "socks5h://127.0.0.1:9050";

		# FAIL: NixOS's systemd hardening prevents these variables to be parsed to the service
			# systemd.services.phpfpm-nextcloud.environment = {
			# 	# "http_proxy='socks5h://127.0.0.1:9050'"
			# 	# "https_proxy='socks5h://127.0.0.1:9050'"
			# 	# "HTTP_PROXY='socks5h://127.0.0.1:9050'"
			# 	# "HTTPS_PROXY='socks5h://127.0.0.1:9050'"
			# 	ALL_PROXY = "socks5h://127.0.0.1:9050";
			# 	all_proxy = "socks5h://127.0.0.1:9050";

			# 	NO_PROXY = "127.0.0.1,localhost";
			# 	no_proxy = "127.0.0.1,localhost";
			# };

		# FAIL: [warn] Rejecting request for anonymous connection to private address [scrubbed] on a TransPort or NATDPort. Possible loop in your NAT rules?
			# services.tor.settings.TransPort = 9040;
			# services.nextcloud.settings.proxy = "socks5h://127.0.0.1:9040";

		# FAIL: No DNS Record found
			# services.tor.settings.DNSPort = 5353;
			# services.tor.settings.TransPort = 9040;

			# networking.firewall.extraCommands = concatStringsSep "\n" [
			# 	# Allow local traffic
			# 	"iptables -t nat -A OUTPUT -m owner --uid-owner nextcloud -d 127.0.0.1 -j RETURN"
			# 	"iptables -t nat -A OUTPUT -m owner --uid-owner nextcloud -d ::1 -j RETURN"

			# 	# Redirect DNS requests to Tor DNSPort
			# 	"iptables -t nat -A OUTPUT -m owner --uid-owner nextcloud -p udp --dport 53 -j REDIRECT --to-ports 5353"

			# 	# Redirect all TCP traffic through Tor TransPort
			# 	"iptables -t nat -A OUTPUT -m owner --uid-owner nextcloud -p tcp -j REDIRECT --to-ports 9040"
			# ];

		# FAIL: Internal server fail
			# Oct 14 13:38:27 mracek nginx[740353]:   thrown in /nix/store/22dy967jvpnilnjs07gq2ynmbzdc8w9k-nextcloud-31.0.9/lib/private/Memcache/Factory.php on line 81" while reading response header from upstream, client: 127.0.0.1, server: nextcloud.nx, request: "PUT /ocs/v2.php/apps/user_status/api/v1/heartbeat?format=json HTTP/2.0", upstream: "fastcgi://unix:/run/phpfpm/nextcloud.sock:", host: "nextcloud.nx"
			# Oct 14 13:38:27 mracek nginx[740353]: 2025/10/14 13:38:27 [error] 740353#740353: *1 FastCGI sent in stderr: "PHP message: PHP Fatal error:  Uncaught OCP\HintException: [0]: Memcache OC\Memcache\APCu not available for local cache (Is the matching PHP module installed and enabled?)
			# systemd.services."phpfpm-nextcloud" = {
			# 	environment = {
			# 		TORSOCKS_ALLOW_INBOUND = toString 1;
			# 	};
			# 	serviceConfig.ExecStart = mkForce (concatStringsSep "\n" [
			# 		"${pkgs.torsocks}/bin/torsocks ${config.services.nextcloud.phpPackage}/bin/php-fpm -y	/nix/store/lnb4zvzzb4dgvafsqa38nbzgnx41ra7q-phpfpm-nextcloud.conf -c /nix/store/71ybhix6bsjli10a46554prrfmcam59p-php.ini"
			# 	]);
			# };

		# FAIL: Does LD_PRELOAD and causes APCu to not be available at runtime
			# systemd.services."phpfpm-nextcloud" = {
			# 	environment = {
			# 		TORSOCKS_ALLOW_INBOUND = toString 1; # Allow torsocks to resolve and proxy connections
			# 	};
			# 	serviceConfig = {
			# 		# Relax systemd hardening so torsocks works
			# 		ProtectSystem = mkForce "off";
			# 		PrivateTmp = mkForce "false";
			# 		PrivateDevices = mkForce "false";
			# 		NoNewPrivileges = mkForce "no";
			# 		RestrictAddressFamilies = mkForce "AF_UNIX AF_INET AF_INET6";

			# 		# Wrap PHP-FPM in torsocks
			# 		ExecStart = mkForce "${pkgs.torsocks}/bin/torsocks ${config.services.nextcloud.phpPackage}/bin/php-fpm -y /nix/store/lnb4zvzzb4dgvafsqa38nbzgnx41ra7q-phpfpm-nextcloud.conf -c /nix/store/7vnaic0pcn0ckn683wn632q85wb9g7k3-php.ini";
			# 	};
			# };

	# OPcache - Mandated by Nextcloud (https://docs.nextcloud.com/server/31/admin_manual/installation/server_tuning.html#enable-php-opcache)
		services.nextcloud.phpOptions."opcache.interned_strings_buffer" = toString 23;
		services.nextcloud.phpOptions."opcache.memory_consumption" = "128";
		services.nextcloud.phpOptions."opcache.max_accelerated_files" = "10000";

	# Notify Push
		# FIXME(Krey): Figure out how to make it work
		services.nextcloud.notify_push.enable = false;
		services.nextcloud.notify_push.bendDomainToLocalhost = false;
		# services.nextcloud.notify_push.nextcloudUrl = "https://localhost";
		# services.nextcloud.secretFile = "${pkgs.writeText "test" ''{"redis":{"password":"insecure"}}''}";
		# systemd.services."nextcloud-notify_push".environment = {
		# 	ALL_PROXY = "127.0.0.1:9050";
		# };
		# systemd.services."nextcloud-notify_push_setup".environment = {
		# 	ALL_PROXY = "127.0.0.1:9050";
		# };
		# networking.hosts = {
		# 	"127.0.0.1" = [ config.services.nextcloud.hostName ];
		# 	"::1" = [ config.services.nextcloud.hostName ];
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

			# 		ExecStart = mkForce "${pkgs.torsocks}/bin/torsocks ${pkgs.nextcloud-notify_push}/bin/notify_push --allow-self-signed /var/lib/nextcloud/config/config.php";
			# 	};
			# };

	# Impermanence
		# environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		# 	{ directory = "${config.services.nextcloud.home}"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		# 	{ directory = "/var/lib/redis-nextcloud"; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rx,o="; }
		# 	(mkIf (config.services.nextcloud.config.dbtype == "pgsql") { directory = "/var/lib/postgresql"; user = "postgres"; group = "postgres"; mode = "u=rwx,g=rx,o="; })
		# ];
}

