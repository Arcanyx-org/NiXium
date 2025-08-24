
{ config, lib, ... }:

# Kira's Firefox Configuration

let
	inherit (lib) mkIf;
in mkIf config.programs.firefox.enable {
	programs.firefox = {
		# Refer to https://mozilla.github.io/policy-templates or `about:policies#documentation` in firefox
		policies = {
			Proxy = {
				Mode = "autoConfig"; # none | system | manual | autoDetect | autoConfig;
				AutoConfigURL = "file://${config.home.homeDirectory}/.config/proxy.pac";
				# AutoLogin = true;
				UseProxyForDNS = true;
			};
		};
	};
}
