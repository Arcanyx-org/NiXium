{ ... }:

# InitRD Management of KRYPTON

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"dm-snapshot"
	];
	boot.initrd.kernelModules = [ ];

	# boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	# Use Systemd initrd
	boot.initrd.systemd.enable = true;
}
