{ config, pkgs, lib, ... }:

# ThinkFan Management of IGNUCIUS

# Levels and their RPMs
# * 0 - Disabled
# * 1 - ~2960 RPM (Minimal Speed)
# * 2 - ~3275 RPM
# * 3 - ~3650 RPM
# * 4 - ~4180 RPM
# * 5 - ~4622 RPM
# * 6 - ~5366 RPM
# * 7 - ~5366 RPM (Maximal controllable speed)
# * 127 ("auto") - Auto, controlled by the Embedded Controller Firmware
# * disengaged - +6800 RPM, significant accelerated wear, controller inability to accurately measure the speed, major noise, only for ShitHitTheFan Scenarios

# To test the various levels: echo level 7 > /proc/acpi/ibm/fan

let
	inherit (lib) mkIf;
in mkIf config.services.thinkfan.enable {
	# Required to be able to control the fan speed (https://github.com/vmatare/thinkfan/issues/45#issuecomment-834864878)
	boot.kernelParams = [ "thinkpad_acpi.fan_control=1" ];

	services.thinkfan.smartSupport = true; # Compile-in the S.M.A.R.T. Support

  # Try to keep the temperature in <70;80> C for peak efficiency
  # The LOW and MAX of each new level has to overlap
	services.thinkfan.levels = [
		[ 0 0 75 ] # Do Not Use The Fan Below 70 C For Power Efficiency
		# Attempt to proactively stabilize the temperatures around the projected peak of power efficiecny
		[ 1 75 76 ]
		[ 2 76 77 ]
		[ 3 77 80 ]
		# Management For Ambient Temperature >40 C
		[ 4 80 85 ]
		[ 5 85 90 ]
		# Management For Extreme Ambient Temperatures
		[ 7 90 100 ] # Maximal Controllable Speed (5366 RPM)
		# Crisis Management - High Ambient Heat or Something Within The Device Generating Lot of Heat
		[ "level disengaged" 100 32767] # +6800 RPM - Max Speed Beyond The Measurable by the controller
	];
}
