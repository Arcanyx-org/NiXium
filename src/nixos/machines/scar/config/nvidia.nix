{ config, lib, ... }:

# Nvidia management of SCAR including optimus

# FIXME-NIXWARE(Krey): This might need some things ported to nixware as sane defaults

let
	inherit (lib) elem optionalString;
	inherit (lib.trivial) release;
in {
	"24.11" = {
		hardware.nvidia = {
			modesetting.enable = true;

			powerManagement.finegrained = true;

			# GTX 1060 (GP106, Pascal) does NOT support the open kernel module
			# (requires Turing/RTX 20 series or newer). Must use proprietary.
			open = false;

			nvidiaSettings = true;

			prime = {
				sync.enable = false;

				reverseSync.enable = false;

				offload.enable = true;
				offload.enableOffloadCmd = true;
			};

			# nvidiaPackages.stable on 24.11 (545.x) supports GTX 1060 natively
			package = config.boot.kernelPackages.nvidiaPackages.stable;
		};

		services.xserver.videoDrivers = [ "nvidia" ];
	};
	"${optionalString (elem release [ "25.05" "25.11" "26.05" ]) release}" = {
		hardware.nvidia = {
			modesetting.enable = true;

			powerManagement.finegrained = true;

			open = false;

			nvidiaSettings = true;

			prime = {
				sync.enable = false;

				reverseSync.enable = false;

				offload.enable = true;
				offload.enableOffloadCmd = true;
			};

			# GTX 1060 (GP106) requires legacy 580.xx driver
			# The production branch (595.xx) ignores this GPU
			package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
		};

		services.xserver.videoDrivers = [ "nvidia" ];
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")
