{ ... }:

# Bootloader management of TUPAC

{
	boot.loader.systemd-boot.enable = false;
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot

	boot.loader.efi.canTouchEfiVariables = true; # Whether the EFI variables are writable
}
