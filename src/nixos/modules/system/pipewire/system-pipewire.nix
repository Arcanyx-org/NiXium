{ lib, config, ... }:

# Global Pipewire Configuration

let
	inherit (lib) mkIf;
in mkIf config.services.pipewire.enable {
	# avahi required for service discovery
	services.avahi.enable = true;

	services.pipewire = {
		raopOpenFirewall = true; # opens UDP ports 6001-6002

		extraConfig.pipewire = {
			"10-airplay" = {
				"context.modules" = [
					{
						name = "libpipewire-module-raop-discover";

						# increase the buffer size if you get dropouts/glitches
						# args = {
						#   "raop.latency.ms" = 500;
						# };
					}
				];
			};
		};
	};
}
