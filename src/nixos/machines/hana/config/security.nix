{ lib, ... }:

# Security management of HANA

let
	inherit (lib) mkMerge mkForce;
in {
	config = mkMerge [
		{
			security.unprivilegedUsernsClone = mkForce true; # Required for current development stack (vscodium)

			# This disables hibernation, so keep it false
			security.protectKernelImage = mkForce false;
		}
	];
}
