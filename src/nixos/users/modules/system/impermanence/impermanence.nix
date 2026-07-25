{ lib, config, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {
	home.persistence."/nix/persist/users/${config.home.username}" = mkIf config.home.impermanence.enable {
		stripHomePrefix = true;
		directories = [
			# HM activation needs to write dconf user file here
			".config/dconf"

			"Desktop"
			"Documents"
			"Downloads"
			"Music"
			"Pictures"
			"Public"
			"Templates"
			"Videos"
			".local/state/nix/profiles"
			".local/state/home-manager"
			".ssh"
			".gnupg"

			# FIXME-QA(Krey): This should be applied only when hexchat is installed
			".config/hexchat"

			# FIXME-QA(Krey): This should be applied only when simplex is installed
			".local/share/simplex"

			# FIXME-QA(Krey): This should be applied only when signal is installed
			# FIXME(Krey): Do not persist the whole signal directory only inject the secrets to perform login
			".config/Signal"

			# FIXME-QA(Krey): Should only be applied if `element-desktop` is installed
			".config/Element" # Element-Desktop

			# Temporary Management for Experimentation, pending better management for purity and functionality
			".config/OrcaSlicer"

			# FIXME-QA(Krey): Should only be applied if gnome keyring is used
			".local/share/keyrings"

			# FIXME-QA(Krey): Should only be applied if fractal is installed
			".local/share/fractal"

			".local/share/PolyMC"

			# FIXME-QA(Krey): Should only be applied if `anime-game-launcher` is installed
			".local/share/anime-game-launcher"

			# FIXME-QA(Krey): Should only be applied if `streamio` is installed
			".stremio-server/stremio-cache"

			# SC-Controller
				# FIXME(Krey): These should have sc-controller nixosConfiguration module defined and set it there
				".config/scc"

			# WINEHQ
				# FIXME(Krey): Apply this only when wine is installed
				".wine"

			# Hydra Launcher
				# FIXME(Krey): Apply this only when hydralauncher is installed
				".config/hydralauncher"

			# Bottles
				# FIXME(Krey): Only apple this when bottles are installed
				".local/share/bottles"

			# Nexus Mods
				# FIXME(Krey): Install this only when nexusmods-app is installed
				".local/share/NexusMods.App"

			# PrusaSliceer
				# FIXME(Krey): Only include this when prusa slicer is installed
				".config/PrusaSlicer"

			# Dorion
				# FIXME(Krey): Only include this when dorion is installed
				".config/dorion"

			# OpenCode
				# FIXME(Krey): Only include this when opencode is installed
				".config/opencode"
				".local/share/opencode"

			".android"

			".local/share/com.jeffser.Alpaca"
		];
		files = [
			(mkIf config.programs.nix-index.enable ".cache/nix-index/files")

			# FIXME-REL(Krey): This option was renamed in 25.11 from services.xserver.desktopManager.gnome and needs compatibility patch here
			(mkIf nixosConfig.services.desktopManager.gnome.enable ".local/share/gnome-shell/application_state") # GNOME Well-Being Usage Data

			# FIXME(Krey): This should only be turned on when flare is installed
			".local/share/flare/db.sqlite"
		];


	};

	home.stateVersion = nixosConfig.system.nixos.release; # Impermanence does not have state
}
