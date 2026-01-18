{ self, config, lib, ... }:

# SINNENFREUDE-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	age.secrets.sinnenfreude-onion-openssh-private = {
		file = ../secrets/sinnenfreude-onion-openssh-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."openssh" = {
		map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH
		# secretKey = "/run/keys/tor/onion/openssh/hs_ed25519_secret_key";
	};

	# Set the pubkey
	environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAXnS4xUPWwjBdKDvvy5OInLbs3oeHUUs5qUsX+fBji root@sinnenfreude";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys

	services.openssh.openFirewall = true;

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];

	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAXnS4xUPWwjBdKDvvy5OInLbs3oeHUUs5qUsX+fBji";

	age.secrets.sinnenfreude-ssh-ed25519-private.file = ../secrets/sinnenfreude-ssh-ed25519-private.age; # Declare private key
}
