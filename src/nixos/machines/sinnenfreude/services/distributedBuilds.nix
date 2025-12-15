{ config, lib, ... }:

# Used to outsource nix's build requirements across available systems in the network, on slow devices such as tablets and battery limited devices such as drones this is essential to configure otherwise nix will drain battery and resources from them
#
# Reference: https://nixos.wiki/wiki/Distributed_build

let
	inherit (lib) mkIf;
in mkIf config.nix.distributedBuilds {
	nix.settings.max-jobs = 1; # Do not build on sinnenfreude as it has issues with thermal management and lacks effective system resources for processing

	# Builders Authorizations
		users.extraUsers.builder.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve" # KREYREN (User)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIGULjxE0+f8yz08cgtU9WtRQtxa3QUIyaw0cILRl/y" # MRACEK (Builder)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtqcZqSQBdWFapn1OPt5fvSmhUN4vSZvvbVwpxT/cip" # TWINKCENTRAL (Builder)
		];

		# Add to known hosts
			programs.ssh.knownHosts."mracek.systems.nx".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8d9Nz64gE+x/+Dar4zknmXMAZXUAxhF1IgrA9DO4Ma";

			programs.ssh.knownHosts."twinkcentral.systems.nx".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcHEgNyhsjEHGaRXKuKopjSgthEn831KGnAXc0c/fLV";

	# Import the SSH Keys for the builder account
	age.secrets.sinnenfreude-builder-ssh-ed25519-private = {
		file = ../secrets/sinnenfreude-builder-ssh-ed25519-private.age;

		owner = "builder";
		group = "builder";
		mode = "400"; # r--------

		path = (if config.boot.impermanence.enable
			then "/nix/persist/system/etc/ssh/ssh_builder_ed25519_key"
			else "/etc/ssh/ssh_builder_ed25519_key");

		symlink = false; # Appears to not work as symlink
	};

	# Set the pubkey
	environment.etc."ssh/ssh_builder_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNpn2sAM07pqQFI3HxiuOxppiEz8OwGDaSMKc7GL8VE";

	nix = {
		buildMachines = [
			{
				# TWINKCENTRAL (Compute)
				hostName = "twinkcentral.systems.nx";
				systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "riscv64-linux" ];
				protocol = "ssh-ng";

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshUser = "builder";
				# sshUser = builder-account;

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshKey = "/etc/ssh/ssh_builder_ed25519_key";
				#sshKey = "${builder-key-path}/ssh_${builder-account}_ed25519_key";

				maxJobs = 4; # 100% of system resources
				speedFactor = 10;
				supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
				mandatoryFeatures = [ ];
			}
			{
				# MRACEK
				hostName = "mracek.systems.nx";
				systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "riscv64-linux" ];
				protocol = "ssh-ng";

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshUser = "builder";
				# sshUser = builder-account;

				# FIXME-QA(Krey): Set this as a variable from nixos/modules/distributedBuilds
				sshKey = "/etc/ssh/ssh_builder_ed25519_key";
				#sshKey = "${builder-key-path}/ssh_${builder-account}_ed25519_key";

				maxJobs = 2; # 50% of system resources
				speedFactor = 1;
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
