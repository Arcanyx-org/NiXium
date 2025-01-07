{
	description = "Kreyren's Infrastructure Management With NiXium";

	inputs = {
		# Release inputs
			nixpkgs-master.url = "github:nixos/nixpkgs/master";
			nixpkgs-staging-next.url = "github:nixos/nixpkgs/staging-next";
			nixpkgs-staging.url = "github:nixos/nixpkgs/staging";
			nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

			nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

			nixpkgs-23_05.url = "github:nixos/nixpkgs/nixos-23.05";
			nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";
			nixpkgs-24_05.url = "github:nixos/nixpkgs/nixos-24.05";
			nixpkgs-24_11.url = "github:nixos/nixpkgs/nixos-24.11";

			nixpkgs-kreyren.url = "github:kreyren/nixpkgs/central";

		# Principle inputs
			nixos-hardware.url = "github:NixOS/nixos-hardware";
			nixos-flake.url = "github:srid/nixos-flake";
			# nur.url = "github:nix-community/NUR/master";
			#impermanence.url = "github:nix-community/impermanence";
			impermanence.url = "github:kreyren/impermanence"; # Use a fork to manage https://github.com/nix-community/impermanence/issues/167
			flake-parts.url = "github:hercules-ci/flake-parts";
			mission-control.url = "github:Platonic-Systems/mission-control";

			flake-root.url = "github:srid/flake-root";
			# NOTE(Krey): Lanzaboote was updated to 0.4.1, but those versions are not compatible with the nixpkgs stable channel
			lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0"; # MAINTAIN(Krey): has to be kept up to date -- https://github.com/nix-community/lanzaboote/issues/343

		arkenfox = {
			url = "github:dwarfmaster/arkenfox-nixos";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		arkenfox-unstable = {
			url = "github:dwarfmaster/arkenfox-nixos";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};
		arkenfox-master = {
			url = "github:dwarfmaster/arkenfox-nixos";
			inputs.nixpkgs.follows = "nixpkgs-master";
		};

		firefox-addons = {
			url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		rust-overlay.url = "github:oxalica/rust-overlay";

		polymc.url = "github:PolyMC/PolyMC";

		# SOPS
			sops = {
				url = "github:Mic92/sops-nix";
				inputs.nixpkgs.follows = "nixpkgs";
			};
			sops-unstable = {
				url = "github:Mic92/sops-nix";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			sops-master = {
				url = "github:Mic92/sops-nix";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		# Ragenix
			ragenix = {
				url = "github:NiXium-org/ragenix";
				inputs.nixpkgs.follows = "nixpkgs";
			};
			ragenix-unstable = {
				url = "github:NiXium-org/ragenix";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			ragenix-master = {
				url = "github:NiXium-org/ragenix";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		# DISKO
			disko = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs";
			};
			disko-unstable = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			disko-master = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		# Jovian
		jovian = {
			url = "git+file:///home/kreyren/src/NiXium/vendor/jovian-nixos";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		# AAGL
			aagl = {
				url = "github:ezKEa/aagl-gtk-on-nix/release-24.11";
				inputs.nixpkgs.follows = "nixpkgs-24_11";
			};

			aagl-24_11 = {
				url = "github:ezKEa/aagl-gtk-on-nix/release-24.05";
				inputs.nixpkgs.follows = "nixpkgs-24_05";
			};
			aagl-24_05 = {
				url = "github:ezKEa/aagl-gtk-on-nix/release-24.05";
				inputs.nixpkgs.follows = "nixpkgs-24_05";
			};
			aagl-23_11 = {
				url = "github:ezKEa/aagl-gtk-on-nix/release-23.11";
				inputs.nixpkgs.follows = "nixpkgs-23_11";
			};

			aagl-unstable = {
				url = "github:ezKEa/aagl-gtk-on-nix/main";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			aagl-master = {
				url = "github:ezKEa/aagl-gtk-on-nix/main";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		# Home-Manager
			hm = {
				url = "github:nix-community/home-manager/release-24.11";
				inputs.nixpkgs.follows = "nixpkgs";
			};

			hm-24_11 = {
				url = "github:nix-community/home-manager/release-24.11";
				inputs.nixpkgs.follows = "nixpkgs-24_11";
			};

			hm-24_05 = {
				url = "github:nix-community/home-manager/release-24.05";
				inputs.nixpkgs.follows = "nixpkgs-24_05";
			};
			hm-23_11 = {
				url = "github:nix-community/home-manager/release-23.11";
				inputs.nixpkgs.follows = "nixpkgs-23_11";
			};

			hm-unstable = {
				url = "github:nix-community/home-manager/master";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			hm-master = {
				url = "github:nix-community/home-manager/master";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		nixos-generators = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-generators-unstable = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};
		nixos-generators-master = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs-master";
		};
	};

	outputs = inputs @ { self, ... }:
		inputs.flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				./src # Import Source Code
				./lib # Implement libs
				./tasks # Include Tasks

				inputs.flake-root.flakeModule
				inputs.mission-control.flakeModule
			];

			# Set Supported Systems
			systems = [
				"x86_64-linux"
				"aarch64-linux"
				"riscv64-linux"
				"armv7l-linux"
			];

			perSystem = { system, config, inputs', ... }: {
				devShells.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
					name = "NiXium-devshell";
					nativeBuildInputs = [
						# Shell
						inputs.nixpkgs.legacyPackages.${system}.bashInteractive # For terminal
						inputs.nixpkgs.legacyPackages.${system}.shellcheck # Linting of shell files

						# Nix
						inputs.nixpkgs.legacyPackages.${system}.nil # Needed for linting
						inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt # Nixpkgs formatter

						# Javascript
						inputs.nixpkgs.legacyPackages.${system}.nodePackages.eslint

						# Secrets
						inputs.ragenix.packages.${system}.default # To manage secrets
						inputs.nixpkgs.legacyPackages.${system}.age # Managing age files

						inputs.nixpkgs.legacyPackages.${system}.sops # Secret management
						inputs.nixpkgs.legacyPackages.${system}.sbctl # To set up secureboot
						inputs.nixpkgs.legacyPackages.${system}.fira-code # For liquratures in code editors

						# Utilities
						inputs.nixpkgs.legacyPackages.${system}.git # Working with the codebase
						inputs.nixpkgs.legacyPackages.${system}.nano # Editor to work with the codebase in cli

						inputs.nixos-generators.packages.${system}.nixos-generate

						inputs.disko.packages.${system}.disko-install
						inputs.disko.packages.${system}.disko

						inputs.nixpkgs.legacyPackages.${system}.ncurses
						inputs.nixpkgs.legacyPackages.${system}.pkg-config
					];
					inputsFrom = [
						config.mission-control.devShell
						config.flake-root.devShell
					];
					# Environmental Variables
					#VARIABLE = "value"; # Comment
				};

				formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
			};
		};
}
