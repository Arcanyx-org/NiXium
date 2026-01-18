{ ... }:

# Bootloader management of IGNUCIUS

{
	# FIXME(Krey): Seems that the keys have to be compiled in coreboot for this to work, TBD management
	boot.lanzaboote.enable = false; # Whether to use NixOS's implementation of secure-boot
	boot.loader.systemd-boot.enable = true;

	boot.loader.efi.canTouchEfiVariables = true;
}
