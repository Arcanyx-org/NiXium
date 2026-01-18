{ pkgs, ... }:

{
	programs.librewolf = {
		package = pkgs.librewolf;
		settings = {
			# Enable letterboxing
			"privacy.resistFingerprinting.letterboxing" = true;

			# WebGL
			"webgl.disabled" = true;

			"browser.preferences.defaultPerformanceSettings.enabled" = false;
			"layers.acceleration.disabled" = true;

			"network.trr.mode" = 3;

			"network.dns.disableIPv6" = false;

			"privacy.donottrackheader.enabled" = true;

			"privacy.clearOnShutdown.history" = true;
			"privacy.clearOnShutdown.downloads" = true;
			"browser.sessionstore.resume_from_crash" = true;

			# See https://librewolf.net/docs/faq/#how-do-i-fully-prevent-autoplay for options
			"media.autoplay.blocking_policy" = 2;

			"privacy.resistFingerprinting" = true;
		};
	};
}
