{ ... }:

# InitRD Management of FLEXY

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"nvme"
		"xhci_pci"
		"rtsx_pci_sdmmc"
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	boot.initrd.systemd.enable = true;
}
