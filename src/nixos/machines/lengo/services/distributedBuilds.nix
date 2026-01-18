{ config, lib, ... }:

# Used to outsource nix's build requirements across available systems in the network, on slow devices such as tablets and battery limited devices such as drones this is essential to configure otherwise nix will drain battery and resources from them
#
# Reference: https://nixos.wiki/wiki/Distributed_build

let
	inherit (lib) mkIf;
in mkIf config.nix.distributedBuilds {
	# Builders Authorizations
		users.extraUsers.builder.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRmGX/iKHM0fwwDjq4fQGt+B8Nj0fJlw7Lq5YA0v3NP" # MORPH (Builder)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve" # KREYREN (User)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhD5Fel4xaocToIQay3IkytHGaK93cDN52ww2Bw5Nj+" # IGNUCIUS (Builder)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIGULjxE0+f8yz08cgtU9WtRQtxa3QUIyaw0cILRl/y" # Mracek (Builder)
		];

		# Add to known hosts
			programs.ssh.knownHosts."mracek.systems.nx".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8d9Nz64gE+x/+Dar4zknmXMAZXUAxhF1IgrA9DO4Ma";
			programs.ssh.knownHosts."morph.systems.nx".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJh5Bd1p4GGCAvNkfoWoflrRIFnoj43b2aMs0GxmULs";

	# Import the SSH Keys for the builder account
	age.secrets.ignucius-builder-ssh-ed25519-private = {
		file = ../secrets/ignucius-builder-ssh-ed25519-private.age;

		owner = "builder";
		group = "builder";
		mode = "400"; # r--------

		path = (if config.boot.impermanence.enable
			then "/nix/persist/system/etc/ssh/ssh_builder_ed25519_key"
			else "/etc/ssh/ssh_builder_ed25519_key");

		symlink = false; # Appears to not work as symlink
	};

	# Set the pubkey
	environment.etc."ssh/ssh_builder_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIID1jLD7ozVGyhMNDsTVrnGcxGmXy7xNiifCQ4osXUbN";

	nix = {
		buildMachines = [
			{
				# MORPH
				hostName = "morph.systems.nx";
				systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
				protocol = "ssh-ng";

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshUser = "builder";
				# sshUser = builder-account;

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshKey = "/etc/ssh/ssh_builder_ed25519_key";
				#sshKey = "${builder-key-path}/ssh_${builder-account}_ed25519_key";

				maxJobs = 8; # 100%, 16GB RAM available
				speedFactor = 10;
				supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
				mandatoryFeatures = [ ];
			}
			{
				# MRACEK
				hostName = "mracek.systems.nx";
				systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
				protocol = "ssh-ng";

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshUser = "builder";
				# sshUser = builder-account;

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshKey = "/etc/ssh/ssh_builder_ed25519_key";
				#sshKey = "${builder-key-path}/ssh_${builder-account}_ed25519_key";

				maxJobs = 2; # 50% of system resources
				speedFactor = 2;
				supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
				mandatoryFeatures = [ ];
			}
		];
	};

	nix.settings = {
		builders-use-substitutes = true; # Use substitutes on the remotes instead of transferring them from host
	};

	# Impermanence
	environment.persistence."/nix/persist/system".files = mkIf config.boot.impermanence.enable [
		"/etc/ssh/ssh_builder_ed25519_key" # Builder account for distributed builds
	];
}
