{ ... }:

# Bootloader management of TUPAC

{
	boot.loader.systemd-boot.enable = true;
	boot.lanzaboote.enable = false; # Whether to use NixOS's implementation of secure-boot

	boot.loader.efi.canTouchEfiVariables = true; # Whether the EFI variables are writable
}
