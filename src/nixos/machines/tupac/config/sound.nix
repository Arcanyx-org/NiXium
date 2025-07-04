{ config, lib, ... }:

# Sound management of TUPAC

let
	inherit (lib) mkMerge;
in mkMerge [
	{
		security.rtkit.enable = true; # Allow real-time scheduling priority to user
	}

	{
		"24.05" = {
			sound.enable = true; # Whether to use ALSA
			hardware.pulseaudio.enable = false; # Whether to use pulseaudio, requires to be turned off if pipewire is used
			services.pipewire.enable = true; # Whether to use pipewire

			# Pipewire
			services.pipewire = {
				alsa.enable = config.sound.enable; # Integrate alse in pipewire
				alsa.support32Bit = config.sound.enable; # Allow 32-bit ALSA support
				pulse.enable = true; # Integrate pulseaudio in pipewire
			};
		};

		# Option 'sound' has been removed
		"24.11" = {
			hardware.pulseaudio.enable = false; # Whether to use pulseaudio, requires to be turned off if pipewire is used
			services.pipewire.enable = true; # Whether to use pipewire

			# Pipewire
			services.pipewire = {
				alsa.enable = true; # Integrate alse in pipewire
				alsa.support32Bit = true; # Allow 32-bit ALSA support
				pulse.enable = true; # Integrate pulseaudio in pipewire
			};
		};
		"25.05" = {
			# `hardware.pulseaudio` (24.11) -> `services.pulseaudio` (25.05)
			services.pulseaudio.enable = false; # Whether to use pulseaudio, requires to be turned off if pipewire is used
			services.pipewire.enable = true; # Whether to use pipewire

			# Pipewire
			services.pipewire = {
				alsa.enable = true; # Integrate alse in pipewire
				alsa.support32Bit = true; # Allow 32-bit ALSA support
				pulse.enable = true; # Integrate pulseaudio in pipewire
			};
		};
	}."${lib.trivial.release}"
]
