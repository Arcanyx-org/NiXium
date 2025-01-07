{ ... }:

# Bootloader management of LENGO

{
	boot.lanzaboote.enable = false; # Whether to use NixOS's implementation of secure-boot

	# Lanzaboote imports it's own systemd bootloader
	boot.loader.systemd-boot.enable = true; # Use SystemD boot loader

	boot.loader.efi.canTouchEfiVariables = true;
}
