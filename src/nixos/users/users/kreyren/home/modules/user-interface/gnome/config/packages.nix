{ config, lib, pkgs, nixosConfig,... }:

# Kreyren's management of GNOME-related packages that are needed to make GNOME to run well

# FIXME-DOCS(Krey): This file is getting complicated, document what packages are needed for what version and what reason

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	{
		"23.11" = {
			home.packages = [
				pkgs.gnome.dconf-editor
				pkgs.pinentry-gnome # Needed for inputting passwords
			];
		};
		"24.05" = {
			home.packages = [
				pkgs.gnome.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords
			];
		};
		"24.11" = {
			home.packages = [
				pkgs.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords
			];
		};
		# FIXME-QA(Krey): Duplicate Code
		"25.05" = {
			home.packages = [
				pkgs.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords
			];
		};
	}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

	{
		home.packages = [
			pkgs.xdg-desktop-portal-gnome
			pkgs.xdg-desktop-portal
		];
	}
])
