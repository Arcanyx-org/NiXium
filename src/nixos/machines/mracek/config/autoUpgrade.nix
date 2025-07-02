{ self, config, lib, ... }:

# The Management of Automatic Upgrades for MRACEK

# Credit: https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/2

# FIXME(Krey): Make the server reboot cleanly each time new update is made to ensure that it's kernel is always up to date

let
	inherit (lib) mkIf;
in mkIf config.system.autoUpgrade.enable {
	system.autoUpgrade = {
		operation = "switch";
		flake = "path:${self.outPath}#nixos-mracek-stable";
		flags = [ "--print-build-logs" ];
		dates = "8h"; # Every Day
		randomizedDelaySec = "2h";
		allowReboot = false;
	};
}