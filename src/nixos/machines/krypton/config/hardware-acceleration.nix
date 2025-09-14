{ config, lib, ... }:

# Hardware-acceleration management of KRYPTON

{
	"24.05" = {
		# The option was renamed on `hardware.graphics` in NixOS 24.11+
		hardware.opengl = {
			enable = true;
			driSupport = true;
		};
	};

	"24.11" = {
		hardware.graphics.enable = true;
	};

	"25.05" = {
		hardware.graphics.enable = true;
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")
