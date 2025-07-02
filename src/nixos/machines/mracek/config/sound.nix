{ config, lib, ... }:

# Sound management of MRACEK

# NOTE(Krey): Sound is expected to never be used and only takes out power -> Disable everything

let
	inherit (lib) mkMerge;
in mkMerge [
	{
		"24.05" = {
			sound.enable = false;

			hardware.pulseaudio.enable = false;

			services.pipewire = {
				enable = false;
				alsa.enable = false;
				alsa.support32Bit = false;
				pulse.enable = false;
			};
		};

		"24.11" = {
			hardware.pulseaudio.enable = false;

			services.pipewire = {
				enable = false;
				alsa.enable = false;
				alsa.support32Bit = false;
				pulse.enable = false;
			};
		};

		"25.05" = {
			hardware.pulseaudio.enable = false;

			services.pipewire = {
				enable = false;
				alsa.enable = false;
				alsa.support32Bit = false;
				pulse.enable = false;
			};
		};
	}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

	{
		security.rtkit.enable = false; # To Get Real-Time priority for Audio
	}
]
