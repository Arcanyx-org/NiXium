{ self, config, lib, ... }:

# Mracek-specific configuration of The Vault Warden

let
	inherit (lib) mkIf;
in mkIf config.services.vaultwarden.enable {
	services.tor.relay.onionServices."vaultwarden".map = mkIf config.services.vaultwarden.enable [ config.services.vaultwarden.config.ROCKET_PORT ]; # Deploy an onion service for the vault warden
}
