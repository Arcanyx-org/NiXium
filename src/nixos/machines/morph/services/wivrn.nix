{ config, lib, pkgs, unstable, ... }:

#! WiVRn service management on MORPH
#: We want to only use MORPH to stream **ONLY THE APPLICATION!** assuming connection to a standalone headset with inside-out tracking as trying to use wired/standalone headset and stream full desktop environment such as StardustXR Desktop with applications will result in a significant performance hit which is likely going to make most of the aplications to run on high latency and bad performance.
#: StardustXR is therefor expected to be used as running on the standalone headset once we figure out how to get a standalone headset with inside-out tracking that has open bootloader to then stream the applications to it.

let
	inherit (lib) mkIf;
in mkIf config.services.wivrn.enable {
	programs.adb.enable = true; # Include ADB as it's used for wired wivrn

	services.wivrn.defaultRuntime = true; # Use Monado

	services.wivrn.openFirewall = true;

	# Q(Krey): Why wouldn't this start by default?
	services.wivrn.autoStart = true;

	# Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
	services.wivrn.config = {
		enable = true;
		json = {
			application = pkgs.wlx-overlay-s;
			scale = 1.0; # 1.0x foveation scaling
			bitrate = 1000000 * 100; # Mb/s
			encoders = [
				{
					# FIXME(Kre): Use 'vulkan' once it's usable
					encoder = "vaapi";
					codec = "h264";
				}
			];
		};
	};
}
