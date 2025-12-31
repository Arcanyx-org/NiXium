{ config, pkgs, ... }:

# Module that implements suspend-then-hibernate for SINNENFREUDE

{
	services.logind.settings.Login = {
		HandlePowerKey = "suspend-then-hibernate"; # Give the user the ability to enforce suspension without hibernation through the power key

		HandlePowerKeyLongPress = "poweroff"; # Long press power key will enforce poweroff

		HandleLidSwitch = "suspend-then-hibernate";

		HandleLidSwitchExternalPower = "suspend";
	};

	systemd.sleep.extraConfig = "HibernateDelaySec=30s";
}
