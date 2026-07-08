{ lib, ... }:

# Sound management of MRACEK

# NOTE(Krey): Sound is expected to never be used and only takes out power -> Disable everything

let
	inherit (lib) mkMerge;
	release = lib.trivial.release;
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

		# Option `sound` was removed in 24.11
		"${lib.optionalString (lib.elem release [ "24.11" "25.05" "26.05" ]) release}" = {
			hardware.pulseaudio.enable = false;

			services.pipewire = {
				enable = false;
				alsa.enable = false;
				alsa.support32Bit = false;
				pulse.enable = false;
			};
		};

		"25.11" = {
			services.pulseaudio.enable = false;

			services.pipewire = {
				enable = false;
				alsa.enable = false;
				alsa.support32Bit = false;
				pulse.enable = false;
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		security.rtkit.enable = false; # To Get Real-Time priority for Audio
	}
]
