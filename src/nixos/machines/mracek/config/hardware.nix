{ ... }:

# Temporary declaration pending NixWare implementation

{
	boot.initrd.availableKernelModules = [
		"xhci_pci"
		"ehci_pci"
		"ahci"
		"usbhid"
		"usb_storage"
		"sd_mod"
		"sr_mod"
	];

	boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

	security.allowSimultaneousMultithreading = false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors and CPU vulnerabilities

	nixpkgs.hostPlatform = "x86_64-linux";
}
