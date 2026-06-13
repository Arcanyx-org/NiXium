{ ... }:

# Bootloader management of SKYCUT

{
	boot.lanzaboote.enable = false;
	boot.loader.systemd-boot.enable = false;

	boot.loader.grub.enable = true;
	boot.loader.generic-extlinux-compatible.enable = true;

	boot.loader.efi.canTouchEfiVariables = false;
}
