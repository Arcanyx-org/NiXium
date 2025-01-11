{ config, lib, ... }:

# Nix-based Disk Management of FLEXY with disko and impermenance on tmpfs

# Formatting strategy:
#    Table: GPT
#    2048 - 1050623 (1048576) -- 512M EFI System
#    1050624 - 479145983 (478095360) -- -10G nix store BTRFS
#    479145984 - 500117503 (20971520) -- 100% Encrypted swap

let
	inherit (lib) mkMerge;

	diskoDevice = "/dev/disk/by-id/nvme-UMIS_RPJTJ256MEE1OWX_SS0W76181Z1CD11J23ED";
in mkMerge [
	{
		age.secrets.flexy-disks-password.file = ../secrets/flexy-disks-password.age; # Supply password for disk encryption
	}

	# FIXME(Krey): Causes infinite recursion, no idea why
	# (if (config.boot.impermenance.enable == true) then {
	(if (true) then {
		age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Change the identity path to use our disko path

		fileSystems."/nix/persist/system".neededForBoot = true;

		# FIXME(Krey): Figure out how to do labels
		disko.devices = {
			nodev."/" = {
				fsType = "tmpfs";
				mountOptions = [
					"size=1G"
					"defaults"
					"mode=755"
				];
			};

			disk = {
				system = {
					device = diskoDevice;
					type = "disk";
					# imageSize = "50G"; # Size of the generated image
					content = {
						type = "gpt";
						partitions = {

							boot = {
								priority = 1; # Needs to be first partition
								type = "EF00"; # EFI System Partition/
								size = "512M";
								content = {
									type = "filesystem";
									format = "vfat"; # FAT32
									mountpoint = "/boot";
								};
							};

							store = {
								priority = 3;
								size = "100%";
								content = {
									name = "store";
									type = "luks";
									settings.allowDiscards = true;

									passwordFile = config.age.secrets.flexy-disks-password.path;

									initrdUnlock = true; # Add a boot.initrd.luks.devices entry for the specified disk

									extraFormatArgs = [
										"--use-random" # use true random data from /dev/random, will block until enough entropy is available
										"--label=CRYPT_NIX"
									];

									extraOpenArgs = [
										"--timeout 10"
									];

									content = {
										type = "btrfs";
										extraArgs = [ "--label NIX_STORE" ];
										subvolumes = {
											"@nix" = {
												mountpoint = "/nix";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
											"@persist" = {
												mountpoint = "/nix/persist/system";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
										};
									};
								};
							};

							swap = {
								priority = 2;
								size = "10G";
								content = {
									name = "swap";
									type = "luks";

									settings.allowDiscards = true;

									passwordFile = config.age.secrets.flexy-disks-password.path;

									initrdUnlock = true; # Add a boot.initrd.luks.devices entry for the specified disk

									extraFormatArgs = [
										"--use-random" # use true random data from /dev/random, will block until enough entropy is available
										"--label=CRYPT_SWAP"
									];

									extraOpenArgs = [
										"--timeout 10"
									];

									content = {
										# FIXME-QA(Krey): Add label 'SWAP'
										type = "swap";
										resumeDevice = true; # resume from hiberation from this device

										extraArgs = [
											"--label SWAP"
										];
									};
								};
							};
						};
					};
				};
			};
		};
	} else {
		age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # Change the identity path to use our disko path

		disk = {
			system = {
				device = diskoDevice;
				type = "disk";
				# imageSize = "50G"; # Size of the generated image
				content = {
					type = "gpt";
					partitions = {

						boot = {
							priority = 1; # Needs to be first partition
							type = "EF00"; # EFI System Partition/
							size = "512M";
							content = {
								type = "filesystem";
								format = "vfat"; # FAT32
								mountpoint = "/boot";
							};
						};

						store = {
							priority = 3;
							size = "100%";
							content = {
								name = "store";
								type = "luks";
								settings.allowDiscards = true;

								passwordFile = config.age.secrets.flexy-disks-password.path;

								initrdUnlock = true; # Add a boot.initrd.luks.devices entry for the specified disk

								extraFormatArgs = [
									"--use-random" # use true random data from /dev/random, will block until enough entropy is available
									"--label=CRYPT_NIX"
								];

								extraOpenArgs = [
									"--timeout 10"
								];

								content = {
									type = "btrfs";
									extraArgs = [ "--label NIX_STORE" ];
									subvolumes = {
										"@nix" = {
											mountpoint = "/nix";
											mountOptions = [ "compress=lzo" "noatime" ];
										};
										"@persist" = {
											mountpoint = "/nix/persist/system";
											mountOptions = [ "compress=lzo" "noatime" ];
										};
									};
								};
							};
						};

						swap = {
							priority = 2;
							size = "10G";
							content = {
								name = "swap";
								type = "luks";

								settings.allowDiscards = true;

								passwordFile = config.age.secrets.flexy-disks-password.path;

								initrdUnlock = true; # Add a boot.initrd.luks.devices entry for the specified disk

								extraFormatArgs = [
									"--use-random" # use true random data from /dev/random, will block until enough entropy is available
									"--label=CRYPT_SWAP"
								];

								extraOpenArgs = [
									"--timeout 10"
								];

								content = {
									# FIXME-QA(Krey): Add label 'SWAP'
									type = "swap";
									resumeDevice = true; # resume from hiberation from this device

									extraArgs = [
										"--label SWAP"
									];
								};
							};
						};
					};
				};
			};
		};
	})
]
