{ config, lib, ... }:

# Nvidia management of TUPAC including optimus

{
	hardware.nvidia = {
		modesetting.enable = true; # Modesetting, which is needed for Wayland compositors

		powerManagement.finegrained = true; # Turns off GPU when not in use

		# Outsource this choice on Nixpkgs
		# open = false; # Whether to use the open-source driver

		nvidiaSettings = true; # Enable Nvidia settings menu

		prime = {
			sync.enable = false; # Sync Mode (always uses the dGPU at the cost of battery efficiency, usually designed for non-portable configuration)

			reverseSync.enable = false; # Reverse-Sync Mode (use iGPU for all rendering and dGPU for display)

			offload.enable = true; # OffLoading Mode (Only use the dGPU when requested)
			offload.enableOffloadCmd = true; # Provide `nvidia-offload` executable to enforce use of dGPU

			intelBusId = "PCI:1:0:0"; # Intel GPU bus
			nvidiaBusId = "PCI:0:2:0"; # Nvidia GPU bus
		};

		package = config.boot.kernelPackages.nvidiaPackages.production; # Which nvidia package to use
	};

	services.xserver.videoDrivers = [ "nvidia" ]; # Make the xserver to use nvidia
}
