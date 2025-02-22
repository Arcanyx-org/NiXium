{ config, pkgs, ... }:

# Module that implements suspend-then-hibernate for LENGO

let
	# NOTE(Krey): After tests in the wild by the user the original 60 doesn't seem sufficient as the device hibernates too quickly and has decent battery life to have a functional battery life with 300s (5 min)
	hibernateSeconds = "300";
in {
	services.logind = {
		powerKey = "suspend-then-hibernate"; # Hibernate on button press
		powerKeyLongPress = "poweroff"; # PowerOff
	};

	systemd.sleep.extraConfig = "HibernateDelaySec=${hibernateSeconds}";
}
