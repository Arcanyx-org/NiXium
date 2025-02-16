{ config, lib, pkgs, ... }:

# VM configuration of IGNUCIUS, used for testing prior to deployment

# Relevant: https://github.com/nix-community/disko/issues/668

# Thank you Maroka-chan for the Cryptkey reference! <3 : https://github.com/Maroka-chan/NixOS-config/blob/c97494c2d725bfb79c0776907a6d89e4724ee21f/modules/base/default.nix#L87

let
	inherit (lib) mkForce;
in {
	# The end Goal Of this configuration is to provide ideally 1:1 emulation of the system to be used as a part of Quality Assurance and to test various deployments
	virtualisation = {
		# nix run -L .#nixosConfigurations.nixos-ignucius-stable.config.system.build.vmWithDisko
		# FIXME(Krey): ignucius-disko-images> hwclock: Cannot access the Hardware Clock via any known method.
		vmVariantWithDisko = {
			virtualisation = {
				# FIXME-QA(Krey): It's weird that this is needed when it's already set in disks.nix
				fileSystems."/nix/persist/system".neededForBoot = true;

				restrictNetwork = false; # Whether to Enable Network Connection

				# More efficient space management as it won't be re-creating store paths in VM
					mountHostNixStore = true;

				# This is enabled by default and it will set up small (~500MB) /nix/.rw-store mount that will cause most of the services to fail loading due to lack of space
					writableStoreUseTmpfs = false;

				# Set Virtual Resolution
					resolution = {
						x = 1280;
						y = 720;
					};

				# Set up the bootloader
					# FIXME-BUG(Krey): Can't be made to work rn as we can't modify `disko.*` to adjust the filesystems for it
					# error: EFI variables can be used only with a partition table of type: hybrid, efi, efixbootldr, or legacy+gpt.
					# useBootLoader = true;
					# # Resolve configuration config
					# 	fileSystems."/boot".device = mkForce "/dev/disk/by-partlabel/disk-system-boot";
					# 	useEFIBoot = true;

				# Secret Management
					# FIXME(Krey): Replace the secrets with dummies so that this can be used by others as well
					# Mount local .ssh directory, so the secrets can be decrypted.
					sharedDirectories."secrets_decryption_key" = {
						source = "/nix/persist/users/kreyren/.ssh";
						target = dirOf (builtins.head config.age.identityPaths);
					};
			};

			# Disable GUI
				services.xserver.enable = mkForce false;
				services.xserver.displayManager.gdm.enable = mkForce false;
				services.xserver.desktopManager.gnome.enable = mkForce false;

			# Do not perform distributed builds as it's not subject of this VM check
				nix.distributedBuilds = mkForce false;

			# Disable S.M.A.R.T. as QEMU VM doesn't provide the relevant endpoints
				# FIXME(Krey): Figure out how to emulate the end-point
				services.smartd.enable = mkForce false; # Disable S.M.A.R.T. Daemon

			# Disable ThinkFan as it errors out as we don't have the /proc/acpi/ibm/thermal in QEMU
				# FIXME(Krey): Figure out how to emulate the end-point
				services.thinkfan.enable = mkForce false; # Disable thinkfan service

			# Use a Dummy Cryptkey so that we don't have to input disk password
				# FIXME(Krey): Any changes to `disko.*` appears to cause `no type option set in` error
				# disko.devices.disk.cryptkey = {
				# 	type = "disk";
				# 	content.type = "gpt";

				# 	content.partitions.cryptkey = {
				# 		size = "4096";
				# 		label = "CRYPTKEY";

				# 		content = {
				# 			type = "filesystem";
				# 			format = "vfat";
				# 		};
				# 	};
				# };

				# disko.devices.disk.system.content.preCreateHook = ''
				# 	mkdir -p /dev/disk/by-partlabel/
				# 	dd bs=1024 count=4 if=/dev/zero of=/dev/disk/by-partlabel/CRYPTKEY iflag=fullblock
				# 	chmod 0400 /dev/disk/by-partlabel/CRYPTKEY
				# '';

				# # Configure the system to use the CRYPTKEY
				# disko.devices.disk.system.content.partitions.store.content.settings = {
				# 	keyFileSize = 4096;
				# 	keyFile = "/dev/disk/by-partlabel/CRYPTKEY";

				# 	# passwordFile = mkForce ""; # Unset Disk Password for the store
				# 	fallbackToPassword = false;
				# };

				# FIXME(Krey): For some reason this results in no option type even when the same configuration works outside of vmVariantWithDisko?
					# error: No type option set in
					# disko.devices.disk.system.content.partitions.store.content.passwordFile = mkForce (pkgs.writeText "ignucius-disks-password" "000000").outPath;

					# disko.devices.disk.system.content.partitions.swap.content.passsssswordFile = mkForce (pkgs.writeText "ignucius-disks-password" "000000").outPath;

					# Also doesn't work:
					# disko.devices.disk.system.content.preCreateHook = ''
					# 	mkdir -p /run/agenix/
					# 	echo 000000 > /run/agenix/ignucius-disks-password
					# '';

					# Doesn't seem to deploy the files
					# system.activationScripts.set-dummy-secrets = ''
					# 	mkdir -p /run/agenix
					# 	echo 000000 > /run/agenix/ignucius-disks-password
					# ''; # Set Permission Of the Persistent Users Directory

			# Disable Swap as it's not needed during VM and only takes space
				# FIXME(Krey): Fails with **No Type option set in**, apparently we can't change disko.* in here?
				# disko.devices.disk.system.content.partitions.swap.size = mkForce null; # Unset swap partition
		};
	};
}
