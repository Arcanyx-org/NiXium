{ lib, ... }:

# Global Bootloader Configuration

let
	inherit (lib) mkDefault;
in {
	boot.loader.timeout = mkDefault 0; # Skip the bootloader menu unless the spacebar is held during the boot
}
