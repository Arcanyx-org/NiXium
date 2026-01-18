{ self, config, lib, ... }:

# Mracek-specific configuration of Vikunja

# FIXME-TRANSPARENCY(Krey): Figure out a declarative way to do user-management as currently new users are added via CLI: `# vikunja create users ...` which is not transparent

let
	inherit (lib) mkIf;
in mkIf config.services.vikunja.enable {
	# Import the private key for an onion service
	age.secrets.mracek-onion-vikunja-private = mkIf config.services.tor.enable {
		file = ../secrets/mracek-onion-vikunja-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/vikunja/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	# Deploy The Onion Service
	services.tor.relay.onionServices."vikunja" = {
		map = mkIf config.services.tor.enable [{
			target = { port = config.services.vikunja.port; };
			port = 80;
		}];
	};

	# FIXME(Krey): We should set up a self-signed certificate for the HTTPS here as added security layer on top of Tor
	services.vikunja.frontendScheme = "http";

	services.vikunja.frontendHostname = "vikunja.nx";

	services.vikunja.settings.service.enableregistration = false; # Disable new registrations

	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [{
		directory = "/var/lib/private/vikunja";
		user = "vikunja";
		group = "vikunja";
		mode = "u=rwx,g=,o=";
	}];

	# FIXME(Krey): Figure out a backup solution
}
