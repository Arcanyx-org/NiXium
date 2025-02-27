{ config, self, moduleWithSystem, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.kreyren = moduleWithSystem (
			perSystem@{ system }:
			{ ... }: {
				home-manager.users.kreyren = {
					imports = [
						self.inputs.arkenfox.hmModules.default
						self.inputs.ragenix.homeManagerModules.default
						self.inputs.impermanence.nixosModules.home-manager.impermanence

						homeManagerModules.default # Include NiXium Home Modules

						./home.nix

						homeManagerModules.modules-kreyren

						# FIXME-QA(Krey): This is kinda weird and i haven't yet decided how to handle it as it should be per-system configurable
						homeManagerModules.ui-gnome-theme-generic-kreyren # Use Generic GNOME Theme
					];
				};

				# Include Import Arguments
				# FIXME-MANAGEMENT(Krey): This should be included for all users by default
				home-manager.extraSpecialArgs = {
					inherit self;

					staging-next = self.inputs.nixpkgs-staging-next.legacyPackages."${system}";
					unstable = self.inputs.nixpkgs-unstable.legacyPackages."${system}";
					stable = self.inputs.nixpkgs.legacyPackages."${system}";
					nixpkgs-24_05 = self.inputs.nixpkgs-24_05.legacyPackages."${system}";

					aagl = self.inputs.aagl.packages."${system}";
					polymc = self.inputs.polymc.packages."${system}";
					firefox-addons = self.inputs.firefox-addons.packages."${system}";
				};
			});

	imports = [
		./machines
		./modules
	];
}
