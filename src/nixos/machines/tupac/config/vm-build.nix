{ lib, pkgs, ... }:

# VM configuration of TUPAC, used for testing prior to deployment

{
	# Disko-specific VM variant (full system with disko)
	# Usage:
	#   CLI:  nix run .#nixosConfigurations.nixos-tupac-stable.config.system.build.vmWithDisko -- -nographic
	#   GUI:  nix run .#nixosConfigurations.nixos-tupac-stable.config.system.build.vmWithDisko
	virtualisation.vmVariantWithDisko = {
		system.stateVersion = lib.versions.majorMinor lib.version;

		# VM resources
		virtualisation = {
			memorySize = 1024 * 2;
			cores = 2;
		};

		virtualisation.fileSystems."/nix".neededForBoot = true;
		virtualisation.fileSystems."/nix/persist/system".neededForBoot = true;
		virtualisation.fileSystems."/nix/persist/users".neededForBoot = true;

		# Override disko image size for VM (smaller than hardware)
		disko.devices.disk.system.imageSize = "64G";

		# Override LUKS store partition to plain btrfs for VM
		disko.devices.disk.system.content.partitions.store = lib.mkForce {
			priority = 3;
			size = "100%";
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

		# Override LUKS swap partition to plain swap for VM (smaller size)
		disko.devices.disk.system.content.partitions.swap = lib.mkForce {
			priority = 2;
			size = "4G";
			content = {
				type = "swap";
				resumeDevice = false;
				extraArgs = [ "--label SWAP" ];
			};
		};

		users.users.root.password = "000000";

		users.users.kreyren = {
			password = "000000";
			hashedPasswordFile = lib.mkForce null;
		};
	};

	# Pulse check VM uses specialisation - see specialisations.nix
	# Usage:
	#   nix build .#nixosConfigurations.nixos-tupac-stable.config.system.build.vmWithDisko --out-link /tmp/vm-pulse
	#   /tmp/vm-pulse/bin/run-tupac-vm -nographic
	#
	# To enable pulse check:
	#   nixos-rebuild build-vm --flake .#nixos-tupac-stable --specialisation pulseCheck
	#   ./result/bin/run-tupac-vm -nographic
	#
	# NOTE: Specialisation currently applies to vmVariant, not vmVariantWithDisko.
	# This is a stub for future experimentation.
}
