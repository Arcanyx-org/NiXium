{ config, lib, pkgs, ... }:

# Sound management of TUPAC

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
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

		# Option 'sound' was removed in 24.11
		"${optionalString (elem release [ "24.11" "25.05" "25.11" ]) release}" = {
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
	}."${release}"

	{
		security.rtkit.enable = true; # Allow real-time scheduling priority to user

		environment.systemPackages = [
			# FIXME-QA(Krey): Sub-optimal.. Should be included on all desktops if GTK with pipewire is used
			# FIXME-QA(Krey): Ideologically this might be better placed at user's management to keep systems bare minimum.. to be decided later
			(mkIf config.services.desktopManager.gnome.enable pkgs.helvum) # Include patchbay for pipewire
		];
	}
]
