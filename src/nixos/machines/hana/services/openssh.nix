{ self, config, lib, ... }:

# HANA-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	# age.secrets.hana-onion-openssh-private = {
	# 	file = ../secrets/hana-onion-openssh-private.age;

	# 	owner = "tor";
	# 	group = "tor";

	# 	path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

	# 	symlink = false; # Appears to not work as symlink
	# };

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	# FIXME-SECURITY(Krey): Wrong placeholder key (from ignucius) — uncomment and set correct hana SSH host public key (AAAAICZ2SsM9PkGXuiulbEFSRJhcs1Vq20L+4pr7DRRFxreb from secrets.nix)
	# environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZ2SsM9PkGXuiulbEFSRJhcs1Vq20L+4pr7DRRFxreb root@hana";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys

	services.openssh.openFirewall = true;
}
