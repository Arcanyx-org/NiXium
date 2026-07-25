{ self, config, lib, ... }:

# TUPAC-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
		# age.secrets.tupac-onion-openssh-private = {
		# 	file = ../secrets/tupac-onion-openssh-private.age;

		# 	owner = "tor";
		# 	group = "tor";

		# 	path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

		# 	symlink = false; # Appears to not work as symlink
		# };

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmYpmNkpSkSSk1FnxHvPb8JlbeYh2lf3d5u8MBqGpHP root@tupac";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];

	programs.ssh.knownHosts."localhost".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpbUbuXYWfIdh4w3FI++1/1Zwhg/ow/FVr8r2kC1bhL";

	age.secrets.tupac-ssh-ed25519-private.file = "${self.outPath}/src/nixos/machines/tupac/secrets/tupac-ssh-ed25519-private.age"; # Declare private key
}
