{ config, lib, pkgs, ...}:

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

	# Set permission for the users directory
	systemd.services.setUserPersistPermissions = {
		description = "Set ownership and permissions for /nix/persist/users";
		wantedBy = [ "multi-user.target" ];
		after = [ "local-fs.target" ];  # Ensure this runs after the filesystem is mounted
		script = builtins.concatStringsSep "\n" [
			"${pkgs.coreutils}/bin/chown root:users /nix/persist/users"
			"${pkgs.coreutils}/bin/chmod 770 /nix/persist/users"
		];
	};

	age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Add impermenant path for keys

	# Needed for impermanence in home-manager
	programs.fuse.userAllowOther = true;
}
