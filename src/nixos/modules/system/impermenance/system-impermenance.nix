{ config, lib, ... }:

let
	inherit (builtins) attrNames attrValues dirOf;
	inherit (lib) mkIf mkMerge filterAttrs mapAttrsToList flatten
		hasPrefix filter;
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
		# Also creates nix per-user profile dirs needed by home-manager activation
		# Always enabled regardless of impermanence since it's needed for user directories
		systemd.tmpfiles.rules =
			let
				userNames = attrNames config.home-manager.users;

				# User persistence base dir
				persistDirRules = map (username: let
					user = config.users.users.${username};
					uid = user.uid;
					gid = if user.group != null then user.group else "users";
				in
					"d /nix/persist/users/${username} 0755 ${toString uid} ${gid}"
				) userNames;

			# Nix per-user profile dir
			nixProfileRules = map (username: let
				user = config.users.users.${username};
				uid = user.uid;
			in
				"d /nix/var/nix/profiles/per-user/${username} 0755 ${toString uid} users"
			) userNames;

			# Home state dirs — tmpfs roots need correct ownership for
			# home-manager activation (gcroots, profile symlinks, dconf)
			homeStateRules = map (username: let
				user = config.users.users.${username};
				uid = user.uid;
				gid = if user.group != null then user.group else "users";
			in [
				"d /home/${username}/.local/state/home-manager/gcroots 0755 ${toString uid} ${gid} -"
				"d /home/${username}/.local/state/nix/profiles 0755 ${toString uid} ${gid} -"
				"d /home/${username}/.config/dconf 0755 ${toString uid} ${gid} -"
			]) userNames;

				# Generate tmpfiles rules so persistence SOURCE paths exist
				# before systemd mount units run.
				mkWhat = psp: sourcePath:
					if hasPrefix "/" sourcePath
					then "${psp}${sourcePath}"
					else "${psp}/${sourcePath}";

				nullToDash = v: if v != null then v else "-";

				mkDirRule = psp: entry: let
					what = mkWhat psp entry.sourcePath;
					u = nullToDash (entry.user or null);
					g = nullToDash (entry.group or null);
					m = nullToDash (entry.mode or null);
				in "d ${what} ${m} ${u} ${g} -";

				mkFileParentRule = psp: entry: let
					what = mkWhat psp entry.sourcePath;
					parentDir = dirOf what;
					pd = entry.parentDirectory or {};
					u = nullToDash (pd.user or null);
					g = nullToDash (pd.group or null);
					m = nullToDash (pd.mode or null);
				in "d ${parentDir} ${m} ${u} ${g} -";

				mkStoreRules = psp: store:
					(map (mkDirRule psp) (store.directories or []))
					++ (map (mkFileParentRule psp) (store.files or []));

				# System stores
				systemStores = filter (s: s.enable or true)
					(attrValues (config.environment.persistence or {}));

				systemAllStores = flatten (map (store:
					let psp = store.persistentStoragePath; in
					[ (mkStoreRules psp store) ]
					++ (map (userStore: mkStoreRules psp userStore)
						(attrValues (store.users or {})))
				) systemStores);

				# HM user persistence SOURCE stores
				hmStores = flatten (mapAttrsToList (_: hm:
					map (hmStore:
						mkStoreRules hmStore.persistentStoragePath hmStore
					) (attrValues (hm.home.persistence or {}))
				) (config.home-manager.users or {}));

			in
				persistDirRules
				++ nixProfileRules
				++ flatten homeStateRules
				++ flatten systemAllStores
				++ hmStores;

	# Impermanence-specific configuration
	environment.persistence = {
		"/nix/persist/system" = {
			hideMounts = true;
			directories = [
				"/var/log"
				"/var/lib/bluetooth"
				"/var/lib/systemd/coredump"
				"/etc/NetworkManager/system-connections"
				{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "0750"; }
				{ directory = "/var/lib/private"; user = "root"; group = "root"; mode = "0700"; }
			] ++ lib.optional config.virtualisation.waydroid.enable "/var/lib/waydroid"
				++ lib.optional config.services.fprintd.enable "/var/lib/fprint"
				++ lib.optional config.services.ollama.enable "/var/lib/private/ollama";
			files = [
				"/etc/machine-id"
				"/var/lib/systemd/random-seed"
				"/etc/ssh/ssh_host_ed25519_key"
				"/etc/ssh/ssh_host_ed25519_key.pub"
				"/etc/ssh/ssh_host_rsa_key"
				"/etc/ssh/ssh_host_rsa_key.pub"
			];
		};
	};

	# Generate proper fileSystems entries for bind-mounted persistence dirs.
	# The vendored impermanence creates systemd.mount units with correct source
	# paths, but NixOS also needs fileSystems entries so the fstab and
	# systemd-fstab-generator produce correct initrd mount units. Without this,
	# the fstab gets device="none" which makes systemd-initrd fail to bind-mount.
	fileSystems = lib.mkMerge [
		(lib.mkIf (config.environment.persistence ? "/nix/persist/system") (
			let
				psp = config.environment.persistence."/nix/persist/system".persistentStoragePath;
			in builtins.listToAttrs (map (dir:
				let
					name = if lib.isString dir then dir else dir.directory;
					sourcePath = if lib.isString dir then dir else (dir.sourcePath or dir.directory);
					device = "${psp}${sourcePath}";
				in {
					inherit name;
					value = {
						inherit device;
						fsType = lib.mkDefault "none";
						options = [ "bind" ];
						neededForBoot = lib.mkDefault true;
					};
				}
			) (config.environment.persistence."/nix/persist/system".directories or []))
		))
	];

		boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
		systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

		age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ];

		programs.fuse.userAllowOther = true;

		system.stateVersion = lib.versions.majorMinor lib.version;
	})
]
