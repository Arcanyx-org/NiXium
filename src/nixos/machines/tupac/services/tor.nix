{ self, config, lib, ... }:

# TUPAC-specific configuration of Tor

let
	inherit (lib) mkIf;
in mkIf config.services.tor.enable {
	services.tor.client.enable = config.services.tor.enable; # Provides Port 9050 with gateway to Tor

	services.tor.relay.enable = config.services.tor.enable; # Work as a relay to obstruct network sniffing
}
