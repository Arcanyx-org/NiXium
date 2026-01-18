{ ... }:

# Bootloader management of SINNENFREUDE

{
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot
	boot.loader.systemd-boot.enable = false;

	security.tpm2.enable = true;

	boot.loader.efi.canTouchEfiVariables = true;
}
