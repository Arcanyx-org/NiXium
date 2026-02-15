{ config, pkgs, lib, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {

	# Add flatpak definitions here..

	# Impermanence
		home.persistence."/nix/persist/users/kreyren".directories = mkIf config.home.impermanence.enable [
			".local/share/flatpak"
		];
}
