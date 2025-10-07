{ config, lib, ... }:

# Global Configuration of Monero

let
	inherit (lib) mkIf;
in mkIf config.services.monero.enable {
	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		(mkIf config.services.monero.enable {
			directory = config.services.monero.dataDir;
			user = "monero";
			group = "monero";
			mode = "u=rwx,g=rx,o=";
		})
	];
}
