{ lib, config, pkgs, ... }:

# Security management of IGNUCIUS

let
	inherit (lib) mkMerge mkForce mkDefault mkIf;
in {
	config = mkMerge [
		{
			security.unprivilegedUsernsClone = mkForce true; # Required for current development stack (vscodium)

			# This disables hibernation, so keep it false
			security.protectKernelImage = mkForce false;
		}
	];
}
