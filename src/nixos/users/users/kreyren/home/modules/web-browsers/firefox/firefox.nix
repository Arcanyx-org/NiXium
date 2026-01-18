{ config, lib, firefox-addons, ... }:

# WELCOME TO THE WORLD OF MINDFUCKERY SUCKAAAA!

let
	inherit (lib) mkForce mkIf;
in mkIf config.programs.firefox.enable {
	programs.firefox = {
		# Refer to https://mozilla.github.io/policy-templates or `about:policies#documentation` in firefox
		policies = {
			# Used For Development
				BlockAboutAddons = false;
				BlockAboutConfig = false;

			# Needed? Ever?
			CaptivePortal = false;

			# TODO(Krey): Experiment with this
				DisableFirefoxAccounts = true; # Disable Firefox Sync

			# TODO(Krey): Figure out how to handle this
			DisableMasterPasswordCreation = true; # To be determined how to handle master password

			DisplayMenuBar = "default-off"; # Whether to show the menu bar

			# FIXME(Krey): Review `~/.mozilla/firefox/Default/extensions.json` and uninstall all unwanted
			# Suggested by t0b0 thank you <3 https://gitlab.com/engmark/root/-/blob/60468eb82572d9a663b58498ce08fafbe545b808/configuration.nix#L293-310
			# NOTE(Krey): Check if the addon is packaged on https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/addons.json the ID can be obtained by trying to install that in firefox
			# Can be used to restrict domains per extension:
				# "restricted_domains": [
				# 	"TEST_BLOCKED_DOMAIN"
				# ]
			ExtensionSettings = {
				"*" = {
					installation_mode = "blocked";
					blocked_install_message = mkForce "FUCKING FORGET IT!";
				};
				"{b43b974b-1d3a-4232-b226-eaa2ac6ebb69}" = {
					# Random User-Agent Switcher
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/random_user_agent/latest.xpi";
					installation_mode = "force_installed";
				};
				"jump-cutter@example.com" = {
					# Jump Cutter
					install_url = "file:///${firefox-addons.jump-cutter}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/jump-cutter@example.com.xpi";
					installation_mode = "force_installed";
				};
				"deArrow@ajay.app" = {
					# DeArrow
					install_url = "file:///${firefox-addons.dearrow}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/deArrow@ajay.app.xpi";
					installation_mode = "force_installed";
				};
				"addon@darkreader.org" = {
					# Dark Reader
					install_url = "file:///${firefox-addons.darkreader}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/addon@darkreader.org.xpi";
					installation_mode = "force_installed";
				};
				"7esoorv3@alefvanoon.anonaddy.me" = {
					# LibRedirect
					install_url = "file:///${firefox-addons.libredirect}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/7esoorv3@alefvanoon.anonaddy.me.xpi";
					installation_mode = "force_installed";
				};
				"jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" = {
					# Terms of Service, Didn't Read
					install_url = "file:///${firefox-addons.terms-of-service-didnt-read}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack.xpi";
					installation_mode = "force_installed";
				};
				"{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
					# Refined Github
					install_url = "file:///${firefox-addons.refined-github}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}.xpi";
					installation_mode = "force_installed";
				};
				# FIXME(Krey): Figure out how to handle this
				# "keepassxc-browser@keepassxc.org" = {
				# 	# KeepAssXC-Browser
				# 	install_url = "file:///${firefox-addons.keepassxc-browser}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/keepassxc-browser@keepassxc.org.xpi";
				# 	installation_mode = "force_installed";
				# };
				# FIXME(Krey): Figure out if we want this
				# "jid1-BoFifL9Vbdl2zQ@jetpack" = {
				# 	# Decentrayeles
				# 	install_url = "file:///${firefox-addons.decentraleyes}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/jid1-BoFifL9Vbdl2zQ@jetpack.xpi";
				# 	installation_mode = "force_installed";
				# };
				# FIXME(Krey): Figure out if we want this
				# "{73a6fe31-595d-460b-a920-fcc0f8843232}" = {
				# 	# NoScript
				# 	install_url = "file:///${firefox-addons.noscript}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/{73a6fe31-595d-460b-a920-fcc0f8843232}.xpi";
				# 	installation_mode = "force_installed";
				# };
				"{74145f27-f039-47ce-a470-a662b129930a}" = {
					# ClearURLs
					install_url = "file:///${firefox-addons.clearurls}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/{74145f27-f039-47ce-a470-a662b129930a}.xpi";
					installation_mode = "force_installed";
				};
				"sponsorBlocker@ajay.app" = {
					# Sponsor Block
					install_url = "file:///${firefox-addons.sponsorblock}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/sponsorBlocker@ajay.app.xpi";
					installation_mode = "force_installed";
				};
				"uBlock0@raymondhill.net" = {
					# uBlock Origin
					install_url = "file:///${firefox-addons.ublock-origin}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/uBlock0@raymondhill.net.xpi";
					installation_mode = "force_installed";
				};
			};
		};
	};
}
