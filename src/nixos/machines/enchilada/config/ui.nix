{ pkgs, ... }:

# Credit: https://github.com/codegod100/mobile-nixos/blob/main/configuration.nix
# Credit: https://github.com/codegod100/mobile-nixos/commit/95be54cf3482b7063674ad4ee1f8b006cdf01d51

{
	# Switch to first virtual console
		systemd.services.phosh = {
			serviceConfig.ExecStartPre = [
				"-${pkgs.kbd}/bin/chvt 1"
			];
		};

	services.gnome.gnome-keyring.enable = true;
	security.pam.services.login.enableGnomeKeyring = true;

	# Auto-login
	services.xserver.desktopManager.phosh = {
		user = "kreyren";
	};

	services.seatd.enable = true;
}
