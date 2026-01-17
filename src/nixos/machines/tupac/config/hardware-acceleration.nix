{ lib, pkgs, ... }:

# Hardware acceleration for TUPAC system

let
	inherit (lib) elem optionalString;
	inherit (lib.trivial) release;
in {
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
	"${optionalString (elem release [ "25.05" "25.11" ]) release}" = {
		hardware.graphics = {
			enable = true;
			extraPackages = with pkgs; [
				intel-media-driver
				(intel-vaapi-driver.override { enableHybridCodec = true; })
				intel-ocl
				intel-compute-runtime
				intel-graphics-compiler
				# vpl-gpu-rt # https://wiki.nixos.org/wiki/Intel_Graphics#Quick_Sync_Video
				# mesa.drivers
				# vulkan-validation-layers
			];

			enable32Bit = true;
			extraPackages32 = with pkgs.pkgsi686Linux; [
				intel-media-driver
				(intel-vaapi-driver.override { enableHybridCodec = true; })
				# intel-ocl
				# intel-compute-runtime
				# intel-graphics-compiler
			];
		};

		# https://nixos.org/manual/nixos/stable/#sec-x11--graphics-cards-intel
		services.xserver.videoDrivers = [ "modesetting" ];

		environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Optionally, set the environment variable
	};
}."${release}" or (throw "Release is not implemented: ${release}")

