{ config, pkgs, ... }:

# Module that implements suspend-then-hibernate for TEMPLATE

let
	hibernateSeconds = "60";
in {
	services.logind = {
		# NOTE(Krey): Temporary until I get a new palmrest with it's magnet
		powerKey = "suspend-then-hibernate"; # Panic Action
		powerKeyLongPress = "poweroff"; # PowerOff
		# Hibernate if not connected to the battery and unused for hibernateSeconds
		lidSwitch = "suspend-then-hibernate";
		# Only suspend if on external power to speed up charging
		lidSwitchExternalPower = "suspend";
	};

	systemd.sleep.extraConfig = "HibernateDelaySec=${hibernateSeconds}";
}
