{ self, config, lib, ... }:

# The Management of Automatic Upgrades for SCAR

# Credit: https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/2

let
	inherit (lib) mkIf;
in mkIf config.system.autoUpgrade.enable {
	system.autoUpgrade = {
		operation = "switch";
		flake = "path:${self.outPath}#nixos-scar-stable";
		flags = [ "--print-build-logs" ];
		dates = "daily"; # Every Day
		randomizedDelaySec = "2h";
		allowReboot = false;
	};
}
