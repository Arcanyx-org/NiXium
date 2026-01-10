{ config, lib, pkgs, ... }:

# Input Management of TUPAC

let
	inherit (lib) elem optionalString;
	inherit (lib.trivial) release;
in {
	# FIXME-BACKPORT(Krey): This configuration was changed in 25.05 and is yet to be backported
	"${optionalString (elem release [ "24.05" "24.11" ]) release}" = {
		# Japanese Keyboard Input
		i18n.inputMethod.enabled = "fcitx5";
		i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

		# Which locales to support
		i18n.supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"cs_CZ.UTF-8/UTF-8"
		];
	};
	"${optionalString (elem release [ "25.05" "25.11" ]) release}" = {
		# Japanese Keyboard Input
		i18n.inputMethod.enable = true;
			i18n.inputMethod.type = "fcitx5";
			i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

		# FIXME(Krey): This should be set in nixium global module as mkDefault
		i18n.defaultLocale = "en_US.UTF-8";

		# Which locales to support
		i18n.supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"cs_CZ.UTF-8/UTF-8"
		];
	};
}."${release}"

