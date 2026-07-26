{ config, lib, pkgs, ... }:

# Global configuration of Tor

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkDefault mkIf;
in mkIf config.services.tor.enable {
	services.tor.relay.role = mkDefault "relay"; # Set relay role as relay by default

	programs.ssh.extraConfig = concatStringsSep "\n" [
		"Host *.onion"
		"ProxyCommand ${pkgs.netcat}/bin/nc -X 5 -x 127.0.0.1:9050 %h %p"

		"Host *.nx"
		"ProxyCommand ${pkgs.netcat}/bin/nc -X 5 -x 127.0.0.1:9050 %h %p"
	];

	# Client Authorization - https://community.torproject.org/onion-services/advanced/client-auth/
		services.tor.settings.ClientOnionAuthDir = mkDefault "${config.services.tor.settings.DataDirectory}/onion_auth"; # Set Client Auth Dir

	# Impermanence
		environment.persistence."/nix/persist/system" = mkIf config.boot.impermanence.enable {
			directories = [
				{
					directory = "${config.services.tor.settings.DataDirectory}";
					user = "tor";
					group = "tor";
					mode = "0750";
				}
				{
					directory = "${config.services.tor.settings.DataDirectory}/onion_auth";
					user = "tor";
					group = "tor";
					mode = "0750";
				}
			];
			files = [
				# FIXME(Krey): Tor seems very unhappy with symlinks..
					# { file = "${config.services.tor.settings.DataDirectory}/state"; parentDirectory = { mode = "u=rwx,g=,o="; }; }

					# Required to prevent Tor's slow startup (~15 min at the worst)
					# 	"${config.services.tor.settings.DataDirectory}/state"

					# # Optimization to reduce stress on the Tor Network and enhance deployment speed
					# 	"${config.services.tor.settings.DataDirectory}/cached-certs"
					# 	"${config.services.tor.settings.DataDirectory}/cached-microdesc-consensus"
					# 	"${config.services.tor.settings.DataDirectory}/cached-microdescs"
					# 	"${config.services.tor.settings.DataDirectory}/cached-microdescs.new"
			];
		};
}

