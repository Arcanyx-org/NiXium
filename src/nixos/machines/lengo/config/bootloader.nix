{ ... }:

# Bootloader management of LENGO

{
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot

	# Lanzaboote imports it's own systemd bootloader
	boot.loader.systemd-boot.enable = false; # Use SystemD boot loader

	boot.loader.efi.canTouchEfiVariables = true;
}
