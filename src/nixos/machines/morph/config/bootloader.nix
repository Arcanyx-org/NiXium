{ ... }:

# Bootloader management of MORPH

{
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot
	boot.loader.systemd-boot.enable = false;

	boot.loader.efi.canTouchEfiVariables = true;
}
