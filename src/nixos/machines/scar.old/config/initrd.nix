{ ... }:

# InitRD Management of SCAR

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"xhci_pci"
		"ahci"
		"usbhid"
		"usb_storage"
		"sd_mod"
		"sdhci_pci"
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	# Use Systemd initrd
	boot.initrd.systemd.enable = true;
}
