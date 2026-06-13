{ self, config, lib, ... }:

# Mracek-specific configuration of Gitea

# FIXME(Krey): Add Admin User

let
	inherit (lib) mkIf;
in mkIf config.services.gitea.enable {
	services.gitea.appName = "KREYREN's Gitea Service";

	# Import the private key for an onion service
	age.secrets.mracek-onion-gitea-private = {
		file = ../secrets/mracek-onion-gitea-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/gitea/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."gitea" = {
		# NOTE(Krey): It's declared this way so that we don't have to use `url.onion:3000` as the web browsers will default to using port 80 for HTTP and port 443 for HTTPS
		map = mkIf config.services.gitea.enable [{ port = 80; target = { port = config.services.gitea.settings.server.HTTP_PORT; }; }]; # Set up Onionized Gitea
	};

	# SSH
	# FIXME(Krey): Figure out the SSH management
	# services.gitea.settings.server.START_SSH_SERVER = true;
	# services.gitea.settings.server.SSH_DOMAIN = "git.gitea.nx";
	# services.gitea.settings.server.SSH_PORT = 8022; # FIXME-QA(Krey): This shouldn't be needed..
	# services.tor.relay.onionServices."hiddenGiteaSSH".map = mkIf config.services.gitea.enable [{
	# 	target = { port = config.services.gitea.settings.server.HTTP_PORT; };
	# 	port = config.services.gitea.settings.server.SSH_PORT;
	# }];
	# age.secrets.mracek-gitea-ssh-onion = {
	# 		file = ./secrets/mracek-gitea-ssh-onion.age;

	# 		owner = "tor";
	# 		group = "tor";
	# 		mode = "0400"; # Only read for the user

	# 		# FIXME(Krey): This should be using `config.services.tor.settings.dataDir`, but that results in `error: infinite recursion encountered` so if we ever change the DataDir then that will have to be changed here as well otherwise it will cause issues
	# 		# path = "${config.services.tor.settings.DataDir}/pelagus-onion.conf";
	# 		path = "/var/lib/tor/mracek-gitea-ssh-onion.conf";

	# 		# FIXME(Krey): has to be without symlink due to bug with link ownership https://github.com/ryantm/agenix/issues/261
	# 		symlink = false;
	# 	};

	# NOTE(Krey): Pending management of secrets for onion addreses for MapAddress
	services.gitea.settings.server.ROOT_URL = "http://gitea.nx"; # Set the ROOT URL needed for UI to know how to show up things

	# FIXME(Krey): This is enterprise-edition-only feature which should be available in the open-source edition -> Propose this to upstream
	services.gitea.settings.security.ENFORCE_TWO_FACTOR_AUTH = true; # Require 2FA to access repositories (https://docs.gitea.com/enterprise/features/mandatory-2fa)

	# FIXME-OID(Krey): Pending implementatio nof OpenID
	# services.gitea.settings.service.DISABLE_REGISTRATION = true;
}
