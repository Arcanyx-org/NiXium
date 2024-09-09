{ self, lib, config, ... }:

# Global Management of Nix for all systems

let
	inherit (builtins) toFile;
	inherit (lib) mkDefault mkIf;
in {
	nix = {
		# package = pkgs.nixUnstable;

		# Set channels
		nixPath = mkDefault [
			"nixpkgs=${self.inputs.nixpkgs}" # Stable
			"unstable=${self.inputs.nixpkgs-unstable}" # Unstable
			"master=${self.inputs.nixpkgs-master}" # Master
			"staging=${self.inputs.nixpkgs-staging}" # Staging
			"staging-next=${self.inputs.nixpkgs-staging-next}" # Staging-Next
		];

		channel.enable = mkDefault false; # Do not use legacy nix-commands

		# Set Flake Registries
		registry = {
			nixpkgs = { flake = self.inputs.nixpkgs; };
			unstable = { flake = self.inputs.nixpkgs-unstable; };
			master = { flake = self.inputs.nixpkgs-master; };
			staging = { flake = self.inputs.nixpkgs-staging; };
			staging-next = { flake = self.inputs.nixpkgs-staging-next; };
			# world = { flake = self.inputs.self; };
		};
		settings = {
			# Since 24.05+ this also needs to be set by the invidual users for their user-based nix daemons to not throw annoying errors asking to use the `--extra-experimental-features`
			experimental-features = "nix-command flakes";
			auto-optimise-store = true;
			#system-features = [ "recursive-nix" ];
			# Nullify the registry for purity
			flake-registry = toFile "empty-flake-registry.json"
				''{"flakes":[],"version":2}'';
		};
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 3d";
			randomizedDelaySec = toString (60 * 60 * 4); # 4 Hours
		};
# FORMATTING(Krey): Pain.. tabs are not processed correctly
    extraOptions = ''
      builders-use-substitutes = true
      min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (2048 * 1024 * 1024)}
    '';
	};

	# Impermanence
	environment.persistence."/nix/persist/system" = mkIf config.boot.impermanence.enable {
		directories = [
			"/var/lib/nixos" # FIXME-DOCS
			"/nix/var/nix/profiles/per-user" # Profiles
		];
		files = [
			"/etc/machine-id" # Unique ID of the system
			{ file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
		];
	};
}
