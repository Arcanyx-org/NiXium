{ ... }:

# InitRD Management of HANA

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	boot.initrd.systemd.enable = true; # Use Systemd initrd
}
