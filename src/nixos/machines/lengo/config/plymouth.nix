{ config, pkgs, lib, ... }:

# Plymouth management of LENGO

# FIXME(Krey): Add solution to input encryption password via touchscreen -> Concluded to be impossible and using unl0kr instead

let
	inherit (lib) mkIf;
in mkIf config.boot.plymouth.enable {
	boot.kernelParams = [
		# Silent Boot
		"quiet"
		"splash"
		"boot.shell_on_fail"
		"loglevel=3"
		"rd.systemd.show_status=false"
		"rd.udev.log_level=3"
		"udev.log_priority=3"
	];

	# More "Silent Boot" stuff
		boot.consoleLogLevel = 0;
		boot.initrd.verbose = false;
}
