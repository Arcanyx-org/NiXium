{ self, config, lib, ... }:

# Mracek-specific configuration of MurMur

let
	inherit (lib) mkIf;
in mkIf config.services.murmur.enable {
	# Import the private key for an onion service
	age.secrets.mracek-onion-murmur-private = {
		file = ../secrets/mracek-onion-murmur-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/murmur/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	# Deploy The Onion Service
	services.tor.relay.onionServices."murmur" = {
		map = mkIf config.services.tor.enable [ config.services.murmur.port ]; # Set up Onionized Murmur
	};
}
