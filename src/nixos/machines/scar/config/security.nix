{ lib, ... }:

# Security management of SCAR

let
	inherit (lib) mkForce;
in {
	# NOTE(Krey): Make it impossible to hibernate
	security.protectKernelImage = mkForce false;

	# NOTE(Krey): Experiment
	security.lockKernelModules = mkForce false;

	security.allowSimultaneousMultithreading = mkForce true; # Disable SMT as it exposes CPU vulnerabilities
}
