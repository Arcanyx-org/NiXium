{ self, config, lib, ... }:

# COOKIE-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	age.secrets.cookie-onion-openssh-private = {
		file = ../secrets/cookie-onion-openssh-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 ADD_ME root@cookie";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys
}
