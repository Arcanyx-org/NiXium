{ ... }:

# InitRD Management of TEMPLATE

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		add modules here
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	# Use Systemd initrd
	boot.initrd.systemd.enable = true;
}
