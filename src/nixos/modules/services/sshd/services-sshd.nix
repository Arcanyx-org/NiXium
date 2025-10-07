{ config, lib, ... }:

# Global configuration of SSHD

# We are using pubkeys for the whole infra as they can't be bruteforced and are more functional

let
	inherit (lib) mkIf mkForce mkDefault;
in mkIf config.services.openssh.enable {
	services.openssh.settings.PasswordAuthentication = mkForce false; # Password Authentification prohibited, require pubkeys

	services.openssh.openFirewall = mkDefault false; # Do not automatically open the firewall

	services.openssh.settings.KexAlgorithms = mkForce [ "sntrup761x25519-sha512@openssh.com" ]; # Allow only Post-Quantum Key Exchange Algorithms

	services.openssh.settings.KbdInteractiveAuthentication = mkForce false; # Do not allow keyboard interactive authorization
}

