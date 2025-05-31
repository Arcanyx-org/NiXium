{ config, lib, ... }:

# Nix-based Disk Management of TUPAC

# Formatting strategy (Impermanence):
#    Table: GPT
#    2048 - 1050623 (1048576) [512M] -- EFI BOOT with FAT32
#    1050624-1874579455 (1873528832) -- -60G Nix Store with BTRFS
#    1874579456-2000408575 (125829120) -- Encrypted SWAP

# Formatting strategy (WITHOUT impermanence):
#    Table: GPT
#    2048 - 1050623 (1048576) [512M] -- EFI BOOT with FAT32
#    1050624-1874579455 (1873528832) -- -60G rootfs with BTRFS
#    1874579456-2000408575 (125829120) -- Encrypted SWAP

let
	inherit (lib) mkMerge;

	diskoDevice = "/dev/disk/by-id/nvme-SOLIDIGM_SSDPFKNU010TZ_BTEH24220RNQ1P0B"; # NVME SSD
in {
	config = mkMerge [
		{
			age.secrets.tupac-disks-password.file = ../secrets/tupac-disks-password.age;
		}

		# FIXME-QA(Krey): Produces an infinite recursion -- (config.boot.impermanence.enable == true)
		(if (true) then {
			age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Change the identity path to use our disko path

			fileSystems."/nix/persist/system".neededForBoot = true;

			# FIXME(Krey): Figure out how to do labels
			disko.devices = {
				nodev."/" = {
					fsType = "tmpfs";
					mountOptions = [
						"size=5G" # >=5GB Needed to avoid no space left errors during rebuilds
						"defaults"
						# set mode to 755, otherwise systemd will set it to 777, which cause problems.
						# relatime: Update inode access times relative to modify or change time.
						"mode=755"
					];
				};

				disk = {
					system = {
						device = diskoDevice;
						type = "disk";
						content = {
							type = "gpt";
							partitions = {

								boot = {
									type = "EF00"; # EFI System Partition/
									start = "2048";
									size = "512M";
									priority = 1; # Needs to be first partition
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
										name = "nix-store";
										type = "luks";
										settings.allowDiscards = true;

										passwordFile = config.age.secrets.tupac-disks-password.path;

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
									size = "60G";
									content = {
										name = "swap";
										type = "luks";

										settings.allowDiscards = true;

										passwordFile = config.age.secrets.tupac-disks-password.path;

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
					content = {
						type = "gpt";
						partitions = {

							boot = {
								type = "EF00"; # EFI System Partition/
								start = "2048";
								end = "1050623"; # +512M
								priority = 1; # Needs to be first partition
								content = {
									type = "filesystem";
									format = "vfat"; # FAT32
									mountpoint = "/boot";
								};
							};

							root = {
								start = "1050624";
								end = "1874579455";
								content = {
									name = "root";
									type = "luks";
									settings.allowDiscards = true;

									passwordFile = config.age.secrets.tupac-disks-password.path;

									initrdUnlock = true; # Add a boot.initrd.luks.devices entry for the specified disk

									extraFormatArgs = [
										"--use-random" # use true random data from /dev/random, will block until enough entropy is available
										"--label=CRYPT_NIXOS"
									];

									extraOpenArgs = [
										"--timeout 10"
									];

									content = {
										type = "btrfs";
										extraArgs = [ "--label ROOT_NIXOS" ];
										subvolumes = {
											"@" = {
												mountpoint = "/";
												mountOptions = [ "compress=lzo" "noatime" ];
											};
										};
									};
								};
							};

							swap = {
								start = "1874579456";
								end = "2000408575";
								content = {
									name = "swap";
									type = "luks";

									settings.allowDiscards = true;

									passwordFile = config.age.secrets.tupac-disks-password.path;

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
	];
}
