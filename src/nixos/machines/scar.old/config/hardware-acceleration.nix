{ lib, ... }:

# Hardware-acceleration management of SCAR

# FIXME(Krey): Move this to NixWare once it's written

let
	inherit (lib) elem optionalString mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"24.05" = {
			# The option was renamed on `hardware.graphics` in NixOS 24.11+
			hardware.opengl = {
				enable = true;
				driSupport = true;
				driSupport32Bit = true;
			};
		};
		"${optionalString (elem release [ "24.11" "25.05" "25.11" "26.05" ]) release}" = {
			hardware.graphics.enable = true;
			hardware.graphics.enable32Bit = true;
		};
  }."${release}" or (throw "Release is not implemented: ${release}")
]
