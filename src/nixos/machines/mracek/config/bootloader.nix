{ ... }:

# Bootloader management of MRACEK

{
	boot.lanzaboote.enable = false;
	boot.loader.systemd-boot.enable = false;
	boot.loader.grub.enable = false;
	boot.loader.generic-extlinux-compatible.enable = true;
	boot.loader.efi.canTouchEfiVariables = false;
}
