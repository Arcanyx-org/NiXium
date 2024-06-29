{ self, config, lib, ... }:

# TUPAC-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	age.secrets.tupac-onion-openssh-private = {
		file = ../secrets/tupac-onion-openssh-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmYpmNkpSkSSk1FnxHvPb8JlbeYh2lf3d5u8MBqGpHP root@tupac";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys
}
