{ ... }:

# Bootloader management of SCAR

{
	boot.loader.systemd-boot.enable = false;
	boot.lanzaboote.enable = true; # Whether to use NixOS's implementation of secure-boot
}
