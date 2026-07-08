{ config, lib, ... }:

# Nvidia management of TUPAC including optimus

let
	inherit (lib) elem optionalString mkMerge;
	inherit (lib.trivial) release;
in {
	"24.11" = {
		hardware.nvidia = {
			modesetting.enable = true;

			powerManagement.finegrained = false;

			open = true;

			nvidiaSettings = true;

			prime = {
				sync.enable = false;

				reverseSync.enable = false;

				offload.enable = true;
				offload.enableOffloadCmd = true;

				intelBusId = "PCI:1:0:0";
				nvidiaBusId = "PCI:0:2:0";
			};

			package = config.boot.kernelPackages.nvidiaPackages.stable;
		};

		services.xserver.videoDrivers = [ "nvidia" ];
	};
	"${optionalString (elem release [ "25.05" "25.11" "26.05" ]) release}" = {
		hardware.nvidia = {
			modesetting.enable = true;

			powerManagement.finegrained = true;

			open = true;

			nvidiaSettings = true;

			prime = {
				sync.enable = false;

				reverseSync.enable = false;

				offload.enable = true;
				offload.enableOffloadCmd = true;

				intelBusId = "PCI:1:0:0";
				nvidiaBusId = "PCI:0:2:0";
			};

			package = config.boot.kernelPackages.nvidiaPackages.production;
		};

		services.xserver.videoDrivers = [ "nvidia" ];
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

