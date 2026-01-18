{ config, lib, ... }:

# Management of Nvidia Drivers for SINNENFREUDE

# Uses GTX 760M

# NOTE(Krey): Legacy GPU supported by driver 470.xx (https://www.nvidia.com/en-us/drivers/unix/legacy-gpu)

let
	inherit (lib) mkIf;

# FIXME-QA(Krey): Figure out a check for Nvidia Drivers
in mkIf false {
	# Configure nVidia including Optimus
	hardware.nvidia = {
		modesetting.enable = true; # Enable modesetting - Needed for Wayland compositors

		# GTX760M is not supported: This version of NVIDIA driver does not provide a corresponding opensource kernel driver
		open = false; # Whether to use the open-source driver

		# Enable Nvidia settings menu
		nvidiaSettings = true;

		## Optionally you may need to select the appropriate driver version for your specific GPU
		package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

		prime = {
			sync.enable = false; # Sync Mode
			offload.enable = true; # OffLoading Mode
			offload.enableOffloadCmd = true; # Provide `nvidia-run` executable to enforce use of dGPU
			intelBusId = "PCI:00:02:0"; # 00:02.0
			nvidiaBusId = "PCI:01:00:0"; # 01:00.0
		};
	};

	services.xserver.videoDrivers = ["nvidia"];
}
