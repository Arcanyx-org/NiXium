{ config, pkgs, lib, ... }:

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

	# Silent boot — suppress kernel/initrd log spew so Plymouth's splash is the only thing visible
	# Ref: https://wiki.nixos.org/wiki/Plymouth#Basic_Config
	boot.kernelParams = [
		"quiet"
		"splash"
		"boot.shell_on_fail"
		"loglevel=3"
		"rd.systemd.show_status=false"
		"rd.udev.log_level=3"
		"udev.log_priority=3"
	];

	boot.consoleLogLevel = 0;
	boot.initrd.verbose = false;
}
