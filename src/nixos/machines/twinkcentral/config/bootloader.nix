{ ... }:

# Bootloader management of TWINKCENTRAL

{
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot

	boot.loader.efi.canTouchEfiVariables = true;
}
