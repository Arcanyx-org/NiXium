{ pkgs, lib, ... }:

# Kernel Management of HANA

let
	inherit (lib) mkForce;
in {
	# FIXME(Krey): Move on harneded kernel, tbd how to manage
	boot.kernelPackages = mkForce pkgs.linuxPackages;

	boot.kernelParams = [
		# SECURITY(Krey): Used to manage CPU Vulnerabilities, tbd how to handle on HANA
			# "tsx=auto" # Let Linux Developers determine if the mitigation is needed
			# "tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
			# "mds=off" # Paranoid enforcement, shouldn't be needed..
	];

	boot.kernelModules = [];
}
