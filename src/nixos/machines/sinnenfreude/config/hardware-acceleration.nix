{ config, lib, ... }:

# Hardware-acceleration management of SINNENFREUDE

# dGPU: GTX 760M

{
	"24.05" = {
		# The option was renamed on `hardware.graphics` in NixOS 24.11+
		hardware.opengl = {
			enable = true;
			driSupport = true;
			driSupport32Bit = true;
		};
	};
	"24.11" = {
		hardware.graphics.enable = true;
		hardware.graphics.enable32Bit = true;
	};
	# FIXME(Krey): Duplicate Code
	"25.05" = {
		hardware.graphics.enable = true;
		hardware.graphics.enable32Bit = true;
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")
