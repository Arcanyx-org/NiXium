{ config, lib, pkgs, ... }:

# WiVRn service management on TUPAC

let
	inherit (lib) mkIf;
in mkIf config.services.wivrn.enable {
	services.avahi = {
		enable = true;
		publish = {
			enable = true;
			userServices = true;
		};
	};

	programs.adb.enable = true; # Include ADB as it's used for wired wivrn

	services.wivrn.defaultRuntime = true; # Use Monado

	services.wivrn.openFirewall = true; # Open ports for Wivrn

	# Only run when wivrn app is openned
	services.wivrn.autoStart = false;

	services.wivrn.monadoEnvironment = {
		# STEAMVR_LH_ENABLE = "1";
		# XRT_COMPOSITOR_COMPUTE = "1";
		U_PACING_COMP_MIN_TIME_MS = "10"; # Recommended by Ai
		WMR_HANDTRACKING = "1"; # Enable hand tracking
	};

	services.wivrn.package = pkgs.wivrn.override { config.cudaSupport = true; }; # Include Nvidia Support for NVENC

	# Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
	services.wivrn.config = {
		enable = true;
		json = {
			application = pkgs.wlx-overlay-s;
			scale = 0.5; # foveation scaling
			# 50~100 Mb/s recommended for wireless, 200 Mb/s for wired, 200 Mb/s is hard coded max
			bitrate = 1000000 * 100; # Mb/s
			# TODO(Krey): Try to use vaapi throug the iGPU instead of the dGPU to spare resources for the application and mitigate the risk of performance hit
			encoders = [
				{
					# dGPU
					encoder = "nvenc";
					codec = "av1";
					width = 1;
					height = 1;
					offset_x = 0;
					offset_y = 0;
					group = 0;
				}
				{ # iGPU
					encoder = "vaapi";
					codec = "av1";
					width = 1;
					height = 1;
					offset_x = 0;
					offset_y = 0;
					group = 1;
				}
			];
		};
	};
}
