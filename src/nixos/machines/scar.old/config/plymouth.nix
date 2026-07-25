{ config, pkgs, lib, ... }:

# Plymouth management of SCAR

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
}
