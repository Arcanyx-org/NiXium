{ ... }:

{
	# FIXME(Krey): We are expecting to use the systemd initrd, but it currently has issues (https://github.com/NixOS/nixpkgs/issues/245089#issuecomment-1646966283)
	boot.initrd.systemd.enable = false;

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
}
