{ ... }:

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		"xhci_pci"
		"nvme"
		"usb_storage"
		"sd_mod"
		"sdhci_pci"
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	boot.initrd.systemd.enable = true;
}
