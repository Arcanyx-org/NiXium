{ config, lib, ... }:

# Hardware Management of SCAR

# FIXME(Krey): This is temporary til nixware is implemented!

let
	inherit (lib) elem optionalString mkForce;
	inherit (lib.trivial) release;
in {
	"24.11" = {
		boot.loader.efi.canTouchEfiVariables = true; # Whether the EFI variables are writable

		hardware.nvidia = {
			prime = {
				intelBusId = mkForce "PCI:1:0:0";
				nvidiaBusId = mkForce "PCI:0:2:0";
			};
		};
	};
	"${optionalString (elem release [ "25.05" "25.11" "26.05" ]) release}" = {
		boot.loader.efi.canTouchEfiVariables = true; # Whether the EFI variables are writable

		hardware.nvidia = {
			prime = {
				intelBusId = mkForce "PCI:0:2:0";
				nvidiaBusId = mkForce "PCI:1:0:1";
			};
		};
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")
