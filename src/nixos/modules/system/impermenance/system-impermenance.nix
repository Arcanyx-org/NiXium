{ config, lib, ... }:

let
	inherit (builtins) attrNames map;
	inherit (lib) mkIf mkMerge;
in mkMerge [
	# Default age identity for VM builds to satisfy ragenix assertion
	# Will be overridden by impermanence config when enabled
	{
		age.identityPaths = [ ];
	}

	# Full config when impermanence is enabled
	(mkIf config.boot.impermanence.enable {
		# Create user persist directories for all users with home-manager
		# This ensures directories exist with correct ownership before home-manager runs
		# Always enabled regardless of impermanence since it's needed for user directories
		systemd.tmpfiles.rules =
			let
				userNames = attrNames config.home-manager.users;
			in
				map (username: let
					user = config.users.users.${username};
					uid = user.uid;
					gid = if user.group != null then user.group else "users";
				in
					"d /nix/persist/users/${username} 0755 ${toString uid} ${gid}"
				) userNames;

		# Impermanence-specific configuration
		environment.persistence = {
			"/nix/persist/system" = {
				hideMounts = true;
				directories = [
					"/var/log"
					"/var/lib/bluetooth"
					"/var/lib/systemd/coredump"
					"/etc/NetworkManager/system-connections"
					{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
					{ directory = "/var/lib/private"; user = "root"; group = "root"; mode = "u=rwx,g=,o="; }
				] ++ lib.optional config.virtualisation.waydroid.enable "/var/lib/waydroid"
					++ lib.optional config.services.fprintd.enable "/var/lib/fprint"
					++ lib.optional config.services.ollama.enable "/var/lib/private/ollama";
				files = [
					"/etc/machine-id"
					"/var/lib/systemd/random-seed"
					"/etc/ssh/ssh_host_ed25519_key"
				];
			};
		};

		boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
		systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

		age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ];

		programs.fuse.userAllowOther = true;

		system.stateVersion = lib.versions.majorMinor lib.version;
	})
]
