{ config, pkgs, lib, ... }:

# Plymouth management of IGNUCIUS

let
	inherit (lib) mkIf;
in mkIf config.boot.plymouth.enable {
	boot.plymouth = {
		theme = "deus_ex";
		themePackages = [
			(pkgs.adi1090x-plymouth-themes.override {
				selected_themes = [ "deus_ex" ];
			})
		];
	};

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
