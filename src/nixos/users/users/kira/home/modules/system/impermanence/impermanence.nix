{ lib, config, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {
	# FIXME-QA(Krey): Should only be used for home-manager NixOS Module, not expected to work in standalone setup!
	home.persistence."/nix/persist/users/kira" = mkIf config.home.impermanence.enable {
		directories = [
			"Desktop"
			"Documents"
			"Downloads"
			"Monero" # For Monero Wallet
			"Music"
			"src" # For project files
			"Pictures"
			"Public"
			"Templates"
			"Videos"
			".gnupg"
			".local/state/nix/profiles"
			".ssh"
			".cache"

			# FIXME-QA(Krey): Should only be applied if gnome keyring is used
			".local/share/keyrings"

			# FIXME-QA(Krey): Should only be applied if direnv is used
			".local/share/direnv"

			".local/share/Steam"

			".local/share/PolyMC"

			(mkIf nixosConfig.services.flatpak.enable ".local/share/flatpak")

			# FIXME-QA(Krey): Should only be applied if `anime-game-launcher` is installed
			".local/share/anime-game-launcher"

			# FIXME-QA(Krey): Should only be applied if `streamio` is installed
			".stremio-server/stremio-cache"
		];
		files = [
			# FIXME-PURITY(Krey): This should be managed declaratively
			".config/monitors.xml"
			(mkIf config.programs.nix-index.enable ".cache/nix-index/files")
		];

		allowOther = true; # FIXME-DOCS(Krey): What is this used for?
	};

	home.stateVersion = nixosConfig.system.nixos.release; # Impermanence does not have state
}
