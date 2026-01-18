{ config, lib, ... }:

# Unl0kr management of LENGO

let
	inherit (lib) mkForce mkIf;
in mkIf config.boot.initrd.unl0kr.enable {
		boot.plymouth.enable = mkForce false; # unl0kr is not designed to work with plymouth

		boot.initrd.unl0kr.settings = {
			keyboard.autohide = false; # Show the Keyboard by Default
			theme.default = "breezy-dark";
		};
}
