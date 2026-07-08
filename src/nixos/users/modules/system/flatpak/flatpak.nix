{ pkgs, lib, config, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in mkIf nixosConfig.services.flatpak.enable {
	# Impermanence — persist flatpak data for all users
		home.persistence."/nix/persist/users/${config.home.username}".directories = mkIf config.home.impermanence.enable [
			".local/share/flatpak"
		];

	# FIXME-QA(Krey): This should be a home-manager module
	systemd.user.services.flathub-init = {
		Unit = {
			Description = "flathub initialization";
			After = [ "network-online.target" ];
			Wants = [ "network-online.target" ];
		};
		Service = {
			Type = "exec";
			ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
		};
		Install = { WantedBy = [ "default.target" ]; };
	};
}
