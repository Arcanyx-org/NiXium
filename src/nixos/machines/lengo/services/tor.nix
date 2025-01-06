{ self, config, lib, ... }:

# IGNUCIUS-specific configuration of Tor

let
	inherit (lib) mkIf;
in mkIf config.services.tor.enable {
	services.tor.client.enable = true; # Provides Port 9050 with gateway to Tor
	services.tor.relay.enable = true; # Work as a relay to obstruct network sniffing
}
