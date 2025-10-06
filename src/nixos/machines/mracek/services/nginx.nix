{ self, config, lib, ... }:

# MRACEK-specific configuration of nginx

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.nginx.enable {
	# Import the private key for an onion service
		age.secrets.mracek-onion-nginx-private = {
			file = ../secrets/mracek-onion-nginx-private.age;

			owner = "tor";
			group = "tor";

			path = "/var/lib/tor/onion/nginx/hs_ed25519_secret_key";

			symlink = false; # Appears to not work as symlink
		};

	services.tor.relay.onionServices."nginx".map = mkIf config.services.tor.enable [
		80 # HTTP
		443 # HTTPS
	];
}
