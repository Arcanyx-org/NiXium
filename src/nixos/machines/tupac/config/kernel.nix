{ pkgs, ... }:

# Kernel management of TUPAC

{
	# Use the stable Xanmod Kernel (https://xanmod.org) as it's designed for high-performance workstation systems to make them more efficient
	boot.kernelPackages = pkgs.linuxPackages; # Specify which kernel to use

	# Kernel Modules
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];
}
