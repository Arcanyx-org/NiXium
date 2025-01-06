{ ... }:

# InitRD Management of LENGO

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"nvme"
		"xhci_pci"
		"thunderbolt"
		"usb_storage"
		"sd_mod"
		"sdhci_pci"
		# May be needed
		# "usbhid"
	];
	boot.initrd.kernelModules = [ ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	# Use Systemd initrd
	boot.initrd.systemd.enable = true;
}
