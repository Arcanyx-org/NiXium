{ self, config, lib, ...}:

# Global Management of Impermanence

let
	inherit (lib) mkIf;
in mkIf config.boot.impermanence.enable {
	environment.persistence."/nix/persist/system" = {
		hideMounts = true;
		directories = [
			"/var/log" # Logs
			"/var/lib/bluetooth" # Keep bluetooth configs

			"/var/lib/systemd/coredump" # Dunno

			"/etc/NetworkManager/system-connections" # WiFi configs

			{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }

			# Users
			{ directory = "/nix/persist/users"; user = "root"; group = "users"; mode = "u=rwx,g=rwx,o="; }
		];
		files = [
			# FIXME(Krey): Should have been in the OpenSSH module
			"/etc/ssh/ssh_host_ed25519_key"
		];
	};

	age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Add impermenant path for keys

	# Needed for impermanence in home-manager
	programs.fuse.userAllowOther = true;
}
