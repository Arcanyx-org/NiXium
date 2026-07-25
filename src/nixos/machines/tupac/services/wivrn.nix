{ config, lib, pkgs, stardust-xr, stardust-startup-script, ... }:

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

# FIXME(Krey): When moving head around at moderate speed the view fails to render and shows passthrough
# FIXME(Krey): AV1 codec not available? Fallsback to something..
# FIXME(Krey): Major performance issues

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkIf;
	inherit (pkgs) runCommand;

	# Script that launches StardustXR inside the WiVRn session
	# StardustXR v0.51.0 (Bevy-based) provides a compositor with native hand tracking
	# Rendering stays on the Intel iGPU (default) and WiVRn encodes on the iGPU via VAAPI;
	# encoding on the NVIDIA dGPU (NVENC) causes frame drops after a few seconds because the
	# dGPU goes idle and drops to P8, starving NVENC.
		vrApp = runCommand "wivrn-app" {
			buildInputs = [ stardust-xr stardust-startup-script ];
			meta.mainProgram = "wivrn-app";
		} (concatStringsSep "\n" [
			"mkdir -p $out/bin"
			"cat > $out/bin/wivrn-app <<'EOF'"
				"#!${pkgs.bash}/bin/bash"
				"exec ${stardust-xr}/bin/stardust-xr-server --xr-only -e ${stardust-startup-script}/bin/startup_script \"$@\""
			"EOF"
			"chmod +x $out/bin/wivrn-app"
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

	# FIXME-SECURITY(Krey): Use Tunnel e.g. VPN
	services.wivrn.openFirewall = true; # Open ports for Wivrn

	# services.wivrn.steam.importOXRRuntimes = true; # Sets `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES` system-wide for testing

	services.wivrn.highPriority = true; # Set High Priority Scheduling

	services.wivrn.autoStart = false; # Don't auto-start on system startup (launch manually)

	services.wivrn.package = pkgs.wivrn.override { config.cudaSupport = true; }; # NVENC built-in but we encode on the Intel iGPU via VAAPI to avoid dGPU P8 drops

	# Config for Monado (https://monado.freedesktop.org/getting-started.html#environment-variables)
	services.wivrn.monadoEnvironment = {
		IPC_EXIT_ON_DISCONNECT = "off"; # Don't exit the service when a client quits
		WMR_HANDTRACKING = "1"; # Enable hand tracking
		U_PACING_COMP_MIN_TIME_MS = "5"; # Address headset view stuttering on NixOS

		XRT_COMPOSITOR_USE_PRESENT_WAIT = "1"; # Reduces Latency on NVIDIA
		XRT_COMPOSITOR_COMPUTE = "1"; # Prevents stuttering if system dips below the maximum refresh rate
		U_PACING_COMP_TIME_FRACTION_PERCENT = "90"; # Commonly paired with Nvidia setups to improve stability []

		# For VAAPI (Intel iGPU encode) — encoding on the iGPU is stable and avoids
		# the dGPU P8 power-drop that starves NVENC after a few seconds
		LIBVA_DRIVER_NAME = "iHD";
		LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
	};

	# Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
	services.wivrn.config = {
		enable = true;
		json = {
			# Launch StardustXR automatically when the Quest connects
			# StardustXR provides a Wayland compositor with native hand tracking
			application = vrApp;

		# 50~100 Mb/s recommended for wireless, 200 Mb/s for wired, 200 Mb/s is hard coded max
		bitrate = 50000000; # 50 Mb/s

		# Encode on the Intel iGPU via VAAPI/QuickSync.
		# Encoding on the NVIDIA dGPU (NVENC) causes frame drops after a few seconds
		# because the dGPU goes idle and drops to P8, starving NVENC.
		encoders = [
			{
				encoder = "vaapi";
				codec = "h265";
				device = "/dev/dri/renderD128"; # Intel iGPU render node
			}
		];
		};
	};

	# Ananicy process scheduling — VR streaming is latency-critical, protected from OOM
	services.ananicy.extraRules = [
		{ name = "wivrn"; type = "Streaming-Server"; oom_score_adj = -900; }
		{ name = "stardust-xr"; type = "Streaming-Server"; oom_score_adj = -900; }
	];

	# Need Git LFS for hand tracking data
		programs.git.enable = true;
			programs.git.lfs.enable = true;

	# StardustXR writes its cursor model to /tmp/stardust_server/models/cursor.glb at startup.
	# oxr_controller.rs does `fs::write(...).expect(...)` and PANICS if the dir is not writable.
	# The dir can be left root-owned (mode 755) if StardustXR was ever launched as root
	# (e.g. a stray root user-service), after which the kreyren-launched transient unit
	# (wivrn-application-*) cannot write to it and the whole VR session crashes.
	# HACK: pre-create the directory world-writable so the write never fails.
	# FIXME-UPSTREAM: StardustXR should handle this write failure gracefully instead of panicking.
	systemd.tmpfiles.rules = [
		# Always enforce 0777 on these dirs (no `!`) so a stale root-owned dir
		# from a previous root wivrn run gets its permissions corrected on next boot.
		"d /tmp/stardust_server 0777 root root -"
		"d /tmp/stardust_server/models 0777 root root -"
		# Remove stale root-owned cursor.glb so kreyren's stardust can recreate it.
		"R /tmp/stardust_server/models/cursor.glb - - - -"
	];
}
