{ config, lib, pkgs, unstable, ... }:

###! # WiVRn service management on TUPAC
###!
###! ## Hardware Specs:
###! Host: T5 V23.2
###! * Display (BOE08B3): 1920x1080 in 16", 144 Hz [Built-in]
###! * DE: GNOME 48.2
###! * WM: Mutter (Wayland)
###! * CPU: 12th Gen Intel(R) Core(TM) i7-12650H (16) @ 4.70 GHz
###! * GPU 1: NVIDIA GeForce RTX 4060 Max-Q / Mobile [Discrete]
###! * GPU 2: Intel UHD Graphics @ 1.40 GHz [Integrated]
###! * Memory: 6.24 GiB / 15.34 GiB (41%)
###! * Swap: 2.18 GiB / 59.98 GiB (4%)
###!
###! Client: META Quest 3
###! * OS: FreeXR pseudo-ROM
###! * Firmware: V76
###!
###! ## This setup kinda has a lot of issues:
###! 1. Vaapi fails with <unknown vulkan error>
###! 2. It is not possible to run group of encoders one using the iGPU and the other offloading on dGPU if the iGPU is running out of system resources for the processing as this is PRIME system that requires `nvidia-offload` to use the Nvidia dGPU which then blocks the iGPU from being used and without it the dGPU can't be used (results in not implemented error)
###! 3. After few seconds of usse it starts to compression artifacts that progressively get worse until the stream crashes which in total takes 6 seconds max no matter what I try to do:
###! 	* Connectiong even over WiFi 6E: On 200Mb/s BT it doesn't even lauch, on 50 Mb/s BT it's somewhat stable but fails after like 14 sec
###!  * Super-speed USB-C: Fails nearly immediately
###! 	* Disabling Hand Tracking: Can't tell if it's getting better
###! 4. Using Stock OS on the client doesn't influence the result

# FIXME(Krey): Remove hard-coded 200mbps max for bitrate

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkIf;
	inherit (pkgs) runCommand;

	# Wrap StardustXR as a session package for GDM
		stardustXRSession = runCommand "stardust-xr-session" {
			buildInputs = [ pkgs.stardust-xr-server ];
			passthru = {
				providedSessions = [ "stardust-xr-server" ]; # session name must match the .desktop filename (without extension)
			};
		} (concatStringsSep "\n" [
			"mkdir -p $out/share/wayland-sessions"
			"cat > $out/share/wayland-sessions/stardust-xr-server.desktop <<EOF"
				"[Desktop Entry]"
				"Name=stardust-xr-server"
				"Comment=Launch StardustXR"
				"Exec=${pkgs.stardust-xr-server}/bin/stardust-xr-server"
				"TryExec=${pkgs.stardust-xr-server}/bin/stardust-xr-server"
				"Type=Application"
			"EOF"
		]);

	# Wrap wlx-overlay-s as a session package for GDM
		wlxOverlaySSession = runCommand "wlx-overlay-s-session" {
			buildInputs = [ pkgs.wlx-overlay-s ];
			passthru = {
				providedSessions = [ "wlx-overlay-s" ]; # session name must match the .desktop filename (without extension)
			};
		} (concatStringsSep "\n" [
			"mkdir -p $out/share/wayland-sessions"
			"cat > $out/share/wayland-sessions/wlx-overlay-s.desktop <<EOF"
				"[Desktop Entry]"
				"Name=wlx-overlay-s"
				"Comment=Launch wlx-overlay-s"
				"Exec=${pkgs.wlx-overlay-s}/bin/wlx-overlay-s"
				"TryExec=${pkgs.wlx-overlay-s}/bin/wlx-overlay-s"
				"Type=Application"
			"EOF"
		]);
in mkIf config.services.wivrn.enable {
	# Required for discovery by the WiVRn client
	services.avahi = {
		enable = true;
		publish = {
			enable = true;
			userServices = true;
		};
	};

	programs.adb.enable = true; # Required for Wired WiVRn

	services.wivrn.defaultRuntime = true; # Use Monado

	# FIXME-SECURITY(Krey): Use Tunnel e.g. VPN
	services.wivrn.openFirewall = true; # Open ports for Wivrn

	# services.wivrn.steam.importOXRRuntimes = true; # Sets `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES` system-wide for testing

	services.wivrn.highPriority = true; # Set High Priority Scheduling

	services.wivrn.autoStart = false; # Run on system startup

	services.wivrn.package = pkgs.wivrn.override { config.cudaSupport = true; }; # Include Nvidia Support for NVENC

	# Config for Monado (https://monado.freedesktop.org/getting-started.html#environment-variables)
	services.wivrn.monadoEnvironment = {
		IPC_EXIT_ON_DISCONNECT = toString false; # Exit the service whenever a client quits
		WMR_HANDTRACKING = toString true; # Enable hand tracking
		U_PACING_COMP_MIN_TIME_MS = toString 5;

		# Enable the Nvidia dGPU
			# NOTE(Krey): Those are needed for CUDA support to not fail as it runs on iGPU otherwise (PRIME)
			__NV_PRIME_RENDER_OFFLOAD = toString true;
			__NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
			__GLX_VENDOR_LIBRARY_NAME = "nvidia";
			__VK_LAYER_NV_optimus = "NVIDIA_only";

		# For VAAPI
			# LIBVA_DRIVER_NAME = "iHD";
	};

	# Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
	services.wivrn.config = {
		enable = true;
		json = {
			# application = runCommand "stardustxr" (concatStringsSep "\n" [
			# 	"${pkgs.stardust-xr-server}/bin/stardust-xr-server &"
			# 	"${pkgs.stardust-xr-flatland}/bin/stardust-xr-flatland &"
			# ]);
			# scale = 0.5; # foveation scaling
			# 50~100 Mb/s recommended for wireless, 200 Mb/s for wired, 200 Mb/s is hard coded max
			bitrate = 1000000 * 10; # Mb/s
			# FIXME(Krey): Try to use vaapi to offload the load on iGPU
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
				# { # iGPU
				# 	encoder = "vaapi";
				# 	device = "/dev/dri/renderD128";
				# 	codec = "h264";
				# 	width = 1;
				# 	height = 1;
				# 	offset_x = 0;
				# 	offset_y = 0;
				# 	# group = 1;
				# }
			];
		};
	};

	# GDM
		services.displayManager.sessionPackages = [
			stardustXRSession # Add StardustXR into GDM
			wlxOverlaySSession # Add wlx-overlay-s into GDM
		];

	# Need Git LFS for hand tracking data
	programs.git.enable = true;
	programs.git.lfs.enable = true;

}
