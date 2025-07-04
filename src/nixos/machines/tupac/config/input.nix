{ config, lib, pkgs, ... }:

# Input Management of TUPAC

{
	"24.05" = {
		# Japanese Keyboard Input
		i18n.inputMethod.enabled = "fcitx5";
		i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

		# Which locales to support
		i18n.supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"cs_CZ.UTF-8/UTF-8"
		];
	};

	"24.11" = {
		# Japanese Keyboard Input
		i18n.inputMethod.enabled = "fcitx5";
		i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];

		# Which locales to support
		i18n.supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"cs_CZ.UTF-8/UTF-8"
		];
	};
	"25.05" = {
		i18n.inputMethod.enable = true;

		i18n.inputMethod = {
			type = "fcitx5";
			fcitx5.addons = with pkgs; [ fcitx5-mozc ];
		};

		i18n.extraLocales = [
			"en_US.UTF-8/UTF-8"
			"cs_CZ.UTF-8/UTF-8"
		];
	};
}."${lib.trivial.release}" or (throw "Release is not implemented in tupac's input: ${lib.trivial.release}")

