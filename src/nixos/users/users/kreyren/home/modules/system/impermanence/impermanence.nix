{ lib, config, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {
	# FIXME-QA(Krey): Should only be used for home-manager NixOS Module, not expected to work in standalone setup!
	home.persistence."/nix/persist/users/kreyren" = mkIf config.home.impermanence.enable {
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

			# FIXME-QA(Krey): This should be applied only when hexchat is installed
			".config/hexchat"

			# FIXME-QA(Krey): This should be applied only when simplex is installed
			".local/share/simplex"

			# FIXME-QA(Krey): Should only be applied if `monero-gui` package is installed
			"Monero"

			# FIXME-QA(Krey): Should only be applied if `element-desktop` is installed
			".config/Element" # Element-Desktop

			# Temporary Management for Experimentation, pending better management for purity and functionality
			".config/OrcaSlicer"

			# FIXME-QA(Krey): Should only be applied if gnome keyring is used
			".local/share/keyrings"

			# FIXME-QA(Krey): Should only be applied if direnv is used
			".local/share/direnv"

			# FIXME-QA(Krey): Should only be applied if fractal is installed
			".local/share/fractal"

			".local/share/PolyMC"

			(mkIf nixosConfig.services.flatpak.enable ".local/share/flatpak")

			# FIXME-QA(Krey): Should only be applied if `anime-game-launcher` is installed
			".local/share/anime-game-launcher"

			# FIXME-QA(Krey): Should only be applied if `streamio` is installed
			".stremio-server/stremio-cache"

			# SC-Controller
				# FIXME(Krey): These should have sc-controller nixosConfiguration module defined and set it there
				".config/scc"
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
