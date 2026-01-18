{ config, lib, self, ... }:

# Nix-based Disk Management of SINNENFREUDE with disko and impermenance on tmpfs

# Formatting strategy:
#    Table: GPT
#    2048 - 1050623 (1048576) -- 512M EFI System
#    1050624 - 913858559 (912807936) -- -30G nix store BTRFS
#    913858560 - 976773119 (62914560) -- 100% Encrypted swap

# Deployment:
#     # nix run 'github:nix-community/disko#disko-install' -- --flake 'github:kreyren/nixos-config#sinnenfreude' --disk system /dev/disk/by-id/ata-WDC_WDS500G2B0A-00SM50_21101J456803

# FIXME(Krey): Refer to https://github.com/nix-community/disko/issues/490

# Reference: https://github.com/ryan4yin/nix-config/blob/82dccbdecaf73835153a6470c1792d397d2881fa/hosts/12kingdoms-suzu/disko-fs.nix#L21

# Reference: https://github.com/lilyinstarlight/foosteros/blob/ccaca3910a61ee790f9cfd000cf77074524676b8/hosts/minimal/disks.nix#L4

let
	inherit (lib) mkMerge;

	diskoDevice = "/dev/disk/by-id/ata-CT500MX500SSD1_21052CD42FFF";
	# keyDevice = "/dev/disk/by-id/mmc-SA02G_0x272bcf2e";
	swapSize = "30G";
	impermanentSize = "5G";
	imageSize = "50G";
in mkMerge [
	{
		age.secrets.sinnenfreude-disks-password.file = "${self.outPath}/src/nixos/machines/sinnenfreude/secrets/sinnenfreude-disks-password.age"; # Supply password for disk encryption
	}

	{
		# 	# Enable SD-Card Unattended-boot

		# 		# Needed to find the SD Card device during initrd stage
		# 		boot.initrd.kernelModules = [ "mmc_core" "mmc_block" "sd_mod"  ];

		# 		age.secrets.lengo-unlock-key.file = ../secrets/template-unlock-key.age; # KeyFile for unlocking the filesystems

		# 		boot.initrd.luks.devices = {
		# 			swap = {
		# 				device = "/dev/disk/by-partlabel/disk-system-swap";
		# 				preLVM = true;
		# 				allowDiscards = true;
		# 				keyFile = keyDevice;
		# 				keyFileSize = 4096;
		# 				# fallbackToPassword = true;
		# 			};
		# 			store = {
		# 				device = "/dev/disk/by-partlabel/disk-system-store";
		# 				preLVM = true;
		# 				allowDiscards = true;
		# 				keyFile = keyDevice;
		# 				keyFileSize = 4096;
		# 				# fallbackToPassword = true;
		# 			};
		# 		};
	}

	# FIXME(Krey): Causes infinite recursion, no idea why
	# (if (config.boot.impermenance.enable == true) then {
	(if (true) then {
	# (mkIf config.boot.impermanence.enable {
		age.identityPaths = [ "/nix/persist/system/etc/ssh/ssh_host_ed25519_key" ]; # Change the identity path to use our disko path

		fileSystems."/nix/persist/system".neededForBoot = true;

		# FIXME(Krey): Figure out how to do labels
		disko.devices = {
			nodev."/" = {
				fsType = "tmpfs";
				mountOptions = [
					"size=${impermanentSize}" # >=8GB Needed to avoid no space left errors during rebuilds
					"defaults"
					"mode=755"
				];
			};

			disk = {
				system = {
					device = diskoDevice;
					type = "disk";
					imageSize = imageSize; # Size of the generated image
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

									passwordFile = config.age.secrets.sinnenfreude-disks-password.path;

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
								size = swapSize;
								content = {
									name = "swap";
									type = "luks";

									settings.allowDiscards = true;

									passwordFile = config.age.secrets.sinnenfreude-disks-password.path;

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
	}
	 else {
		age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # Change the identity path to use our disko path

		disk = {
			system = {
				device = diskoDevice;
				type = "disk";
				imageSize = imageSize; # Size of the generated image
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

								passwordFile = config.age.secrets.sinnenfreude-disks-password.path;

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
							size = swapSize;
							content = {
								name = "swap";
								type = "luks";

								settings.allowDiscards = true;

								passwordFile = config.age.secrets.sinnenfreude-disks-password.path;

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
