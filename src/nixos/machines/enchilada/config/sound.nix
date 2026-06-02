{ config, lib, pkgs, ... }:

# Sound management of ENCHILADA

{
	"25.11" = {
		services.pulseaudio.enable = false; # Whether to use pulseaudio, requires to be turned off if pipewire is used
		services.pulseaudio.package = pkgs.pulseaudioFull;

		services.pipewire.enable = true; # Whether to use pipewire

		# Pipewire
		services.pipewire = {
			alsa.enable = true; # Integrate alse in pipewire
			alsa.support32Bit = true; # Allow 32-bit ALSA support
			pulse.enable = true; # Integrate pulseaudio in pipewire
		};


		security.rtkit.enable = true; # Allow real-time scheduling priority to user
	};
}.${lib.trivial.release} or (throw "Release '${lib.trivial.release}' is not implemented in this module")
