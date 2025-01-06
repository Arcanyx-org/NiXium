{ config, lib, ... }:

# Used to outsource nix's build requirements across available systems in the network, on slow devices such as tablets and battery limited devices such as drones this is essential to configure otherwise nix will drain battery and resources from them
#
# Reference: https://nixos.wiki/wiki/Distributed_build

let
	inherit (lib) mkIf;
in mkIf config.nix.distributedBuilds {
	# Authorized Keys
		users.extraUsers.builder.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhD5Fel4xaocToIQay3IkytHGaK93cDN52ww2Bw5Nj+" # IGNUCIUS (Builder)
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIID1jLD7ozVGyhMNDsTVrnGcxGmXy7xNiifCQ4osXUbN" # LENGO (Builder)
		];

		# Set Known Hosts
		programs.ssh.knownHosts."ignucius.systems.nx".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWL1P+3Bg7rr3NEW2h0I1bXBZtwCpU3IiruewsUQrcg";

	# Import the SSH Keys for the builder account
	age.secrets.mracek-builder-ssh-ed25519-private = {
		file = ../secrets/mracek-builder-ssh-ed25519-private.age;

		owner = "builder";
		group = "builder";
		mode = "660"; # rw-rw----

		path = (if config.boot.impermanence.enable
			then "/nix/persist/system/etc/ssh/ssh_builder_ed25519_key"
			else "/etc/ssh/ssh_builder_ed25519_key");

		symlink = false; # Appears to not work as symlink
	};

	# Set the pubkey
	environment.etc."ssh/ssh_builder_ed25519_key.pub".text = "ssh-ed25519 ssh-ed25519 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIGULjxE0+f8yz08cgtU9WtRQtxa3QUIyaw0cILRl/y builder@mracek";

	# Impermanence
	environment.persistence."/nix/persist/system".files = mkIf config.boot.impermanence.enable [
		"/etc/ssh/ssh_builder_ed25519_key" # Builder account for distributed builds
	];
}
