{ config, lib, ...}:

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

			# FIXME(Krey): Move this to it's own module
			(mkIf config.virtualisation.waydroid.enable "/var/lib/waydroid")

			(mkIf config.services.fprintd.enable "/var/lib/fprint")

			# (mkIf config.services.ollama.enable config.services.ollama.home)
			(mkIf config.services.ollama.enable "/var/lib/private/ollama")
		];
		files = [
			"/etc/machine-id" # Unique ID of the system
			"/var/lib/systemd/random-seed"

			# FIXME(Krey): Should have been in the OpenSSH module
			"/etc/ssh/ssh_host_ed25519_key"
		];
	};

	# TODO(Krey): Pending vendor re-management
		# Hotfix for https://github.com/nix-community/impermanence/issues/229
		boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
		systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];


	# The configuration will deploy the user directories owned by root:root which will cause the user's home manager to fail deployment due to permission denied error, so we need to change the ownership before home-manager setup
		# Plan A
		# system.activationScripts.change-ownership-persist-users = ''chown root:users /nix/persist/users''; # Set Permission Of the Persistent Users Directory

		# Plan B
			# systemd.tmpfiles.rules = [
			# 	"d /persist/home/${username} 0700 ${username} users"
			# 	# We need to explicitly set ownership on the home directory when using impermanence.
			# 	# Otherwise, it will be owned as root, and home-manager will fail.
			# 	"d /home/${username} 0700 ${username} users"
			# ];

	age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Add impermenant path for keys

	# Needed for impermanence in home-manager
	programs.fuse.userAllowOther = true;
}
