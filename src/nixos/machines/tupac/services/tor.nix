{ self, config, lib, ... }:

# TUPAC-specific configuration of Tor

let
	inherit (lib) mkIf;
in mkIf config.services.tor.enable {
	services.tor.client.enable = true; # Provides Port 9050 with gateway to Tor

	services.tor.client.dns.enable = true; # Provide Tor DNS on port

	services.tor.relay.enable = true; # Work as a relay to obstruct network sniffing
}
