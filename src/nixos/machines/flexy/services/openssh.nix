{ self, config, lib, ... }:

# FLEXY-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	# age.secrets.flexy-onion-openssh-private = {
	# 	file = ../secrets/flexy-onion-openssh-private.age;

	# 	owner = "tor";
	# 	group = "tor";

	# 	path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

	# 	symlink = false; # Appears to not work as symlink
	# };

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	# environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8d9Nz64gE+x/+Dar4zknmXMAZXUAxhF1IgrA9DO4Ma root@flexy";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys

	services.openssh.openFirewall = true;
}
