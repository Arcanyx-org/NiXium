{ ... }:

# InitRD Management of TUPAC

{
	boot.initrd.systemd.enable = true;

	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"xhci_pci"
		"nvme"
		"uas"
		"usb_storage"
		"sd_mod"
		"sdhci_pci"
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password
}
