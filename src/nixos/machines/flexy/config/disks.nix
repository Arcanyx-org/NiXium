{ config, lib, ... }:

# Nix-based Disk Management of FLEXY with disko and impermenance on tmpfs

let
	inherit (lib) mkMerge;
	diskoDevice = "/dev/disk/by-id/nvme-UMIS_RPJTJ256MEE1OWX_SS0W76181Z1CD11J23ED";
	swapSize = "10G";
	tempSize = "10G"; # >=10GB Needed to avoid no space left errors during rebuilds
	imageSize = "50G";
in mkMerge [
	{
		age.secrets.flexy-disks-password.file = ../secrets/flexy-disks-password.age; # Supply password for disk encryption

		age.secrets.flexy-unlock-key.file = ../secrets/flexy-unlock-key.age; # KeyFile for unlocking the filesystems

		# Needed to find the SD Card device during initrd stage
		boot.initrd.kernelModules = [ "mmc_core" "mmc_block" "sd_mod"  ];
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
					"size=${tempSize}"
					"defaults"
					"mode=755"
				];
			};

			disk = {
				system = {
					device = diskoDevice;
					type = "disk";
					imageSize = "${imageSize}"; # Size of the generated image
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
									# SECURITY(Krey): Required since systemd 254, to not make the random-seed file writtable by default
									# * https://github.com/nix-community/disko/issues/527#issuecomment-1924076948
									# * https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/14
									mountOptions = [ "umask=0077" ];
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
											"@system-persist" = {
												mountpoint = "/nix/persist/system";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
											"@user-persist" = {
												mountpoint = "/nix/persist/users";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
											# FIXME(Krey): Causes emergency shell
											# "@nixium-persist" = {
											#  	mountpoint = "/nix/persist/NiXium";
											# 	mountOptions = [ "compress=lzo" "noatime" ];
											# };
										};
									};
								};
							};

							swap = {
								priority = 2;
								size = "${swapSize}";
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
				imageSize = "${imageSize}"; # Size of the generated image
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
											"@system-persist" = {
												mountpoint = "/nix/persist/system";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
											"@user-persist" = {
												mountpoint = "/nix/persist/users";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
										};
								};
							};
						};

						swap = {
							priority = 2;
							size = "${swapSize}";
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
