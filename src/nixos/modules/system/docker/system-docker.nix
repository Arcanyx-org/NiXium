{ self, lib, config, ... }:

# Global Management of Docker for all systems

let
	inherit (lib) mkIf;
in mkIf config.virtualisation.docker.enable {
	# Impermanence
	environment.persistence."/nix/persist/system" = mkIf config.boot.impermanence.enable {
		directories = [
			"/var/lib/docker"
		];
	};
}
