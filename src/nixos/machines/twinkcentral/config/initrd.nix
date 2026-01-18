{ ... }:

# InitRD Management of TWINKCENTRAL

{
	# InitRD Kernel Modules
	boot.initrd.availableKernelModules = [
		# Auto-Generated
		"xhci_pci"
		"ahci"
		"ehci_pci"
		"usbhid"
		"sd_mod"
		"sr_mod"
	];
	boot.initrd.kernelModules = [ "kvm-amd" ];

	boot.initrd.includeDefaultModules = true; # Has to be set to true to be able to input decrypting password

	# Use Systemd initrd
	boot.initrd.systemd.enable = true;
}
