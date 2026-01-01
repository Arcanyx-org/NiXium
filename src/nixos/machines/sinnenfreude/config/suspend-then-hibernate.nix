{ config, lib, ... }:

# Module that implements suspend-then-hibernate for SINNENFREUDE

let
	inherit (lib) mkIf mkMerge;
	release = "${lib.trivial.release}";
in mkIf config.powerManagement.enable (mkMerge [
	{
		"${lib.optionalString (lib.elem release [ "24.11" "24.05" "25.05" ]) release}" = {
			services.logind = {
				powerKey = "suspend-then-hibernate";
				powerKeyLongPress = "poweroff";
			};
		};

		"25.11" = {
			services.logind.settings.Login = {
				HandlePowerKey = "suspend-then-hibernate";
				HandlePowerKeyLongPress = "poweroff";
				HandleLidSwitch = "suspend-then-hibernate";
				HandleLidSwitchExternalPower = "suspend";
			};
		};
	}."${release}"

	{
		powerManagement.powertop.enable = true;
		systemd.sleep.extraConfig = "HibernateDelaySec=30s";
	}
])





# { config, lib, ... }:

# # Module that implements suspend-then-hibernate for SINNENFREUDE

# let
# 		inherit (lib) mkIf mkMerge;
# in mkIf config.powerManagement.enable (mkMerge [
# 		{
# 				# Use conditional assignment of the attribute name
# 				"${if lib.elem lib.trivial.release [ "24.11" "24.05" "25.05" ] then "${lib.trivial.release}" else null}" = {
# 						services.logind = {
# 								powerKey = "suspend-then-hibernate";
# 								powerKeyLongPress = "poweroff";
# 						};
# 				};

# 				"${lib.trivial.release}" = {
# 						services.logind.settings.Login = {
# 								HandlePowerKey = "suspend-then-hibernate"; # Give the user the ability to enforce suspension without hibernation through the power key

# 								HandlePowerKeyLongPress = "poweroff"; # Long press power key will enforce poweroff

# 								HandleLidSwitch = "suspend-then-hibernate";

# 								HandleLidSwitchExternalPower = "suspend";
# 						};
# 				};
# 		}."${lib.trivial.release}"

# 		{
# 				powerManagement.powertop.enable = true;

# 				systemd.sleep.extraConfig = "HibernateDelaySec=30s";
# 		}
# ])






# { config, lib, ... }:

# # Module that implements suspend-then-hibernate for SINNENFREUDE

# let
# 	inherit (lib) mkIf mkMerge;
# in mkIf config.powerManagement.enable (mkMerge [
# 	(
# 		(
# 			lib.genAttrs
# 				[ "24.05" "24.11" "25.05" "25.11" ]
# 				(_: {
# 					services.logind = {
# 						powerKey = "suspend-then-hibernate";
# 						powerKeyLongPress = "poweroff";
# 					};
# 				})
# 		)."24.11"
# 	)

# 	{
# 		"24.11" = { };
# 		"25.05" = {
# 			services.logind.settings.Login = {
# 				HandlePowerKey = "suspend-then-hibernate";
# 				HandlePowerKeyLongPress = "poweroff";
# 				HandleLidSwitch = "suspend-then-hibernate";
# 				HandleLidSwitchExternalPower = "suspend";
# 			};
# 		};
# 	}."24.11"

# 	{
# 		powerManagement.powertop.enable = true;
# 		systemd.sleep.extraConfig = "HibernateDelaySec=30s";
# 	}
# ])





# { config, lib, ... }:

# # Module that implements suspend-then-hibernate for SINNENFREUDE

# let
# 	inherit (lib) mkIf mkMerge;
# in mkIf config.powerManagement.enable (mkMerge [
# 	{
# 	(lib.elem lib.trivial.release [ "24.11" "24.05" "25.05" ]) {
# 		services.logind = {
# 			powerKey = "suspend-then-hibernate";
# 			powerKeyLongPress = "poweroff";
# 		};
# 	}
# 		"${lib.trivial.release}" = {
# 			services.logind.settings.Login = {
# 				HandlePowerKey = "suspend-then-hibernate"; # Give the user the ability to enforce suspension without hibernation through the power key

# 				HandlePowerKeyLongPress = "poweroff"; # Long press power key will enforce poweroff

# 				HandleLidSwitch = "suspend-then-hibernate";

# 				HandleLidSwitchExternalPower = "suspend";
# 			};
# 		};
# 	}."${lib.trivial.release}"

# 	{
# 		powerManagement.powertop.enable = true;

# 		systemd.sleep.extraConfig = "HibernateDelaySec=30s";
# 	}
# ])
