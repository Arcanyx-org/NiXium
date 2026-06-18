{ self, config, lib, ... }:

# TEMPLATE-specific configuration of OpenSSH

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.openssh.enable {
	# Import the private key for an onion service
	age.secrets.template-onion-openssh-private = {
		file = ../secrets/template-onion-openssh-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."openssh".map = mkIf config.services.tor.enable config.services.openssh.ports; # Provide hidden SSH

	# Set the pubkey
	# FIXME-SECURITY(Krey): This is a placeholder key copied from ignucius; replace with the actual machine's SSH host public key when deploying from this template
	environment.etc."ssh/ssh_host_ed25519_key.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhD5Fel4xaocToIQay3IkytHGaK93cDN52ww2Bw5Nj+ root@template";

	services.openssh.hostKeys = mkForce []; # Do not generate SSH keys

	services.openssh.openFirewall = true;
}
