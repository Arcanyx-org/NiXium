{ moduleWithSystem, config, self, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.kreyren = moduleWithSystem (
		perSystem@{ system }:
		{ ... }: {
			home-manager.users.kreyren = {
				# These modules are used by default on all systems
				imports = [
					self.inputs.arkenfox.hmModules.default
					self.inputs.ragenix.homeManagerModules.default
					self.inputs.impermanence.nixosModules.home-manager.impermanence

					./home.nix

					# FIXME(Krey): Broken on impermanent setup after `switch`
					#homeManagerModules.apps-flameshot-kreyren

					# FIXME-QA(Krey): Expected to be just `homeManagerModules.editors-kreyren` same for all others..
					homeManagerModules.editors-vim-kreyren
					homeManagerModules.editors-vscode-kreyren

					#homeManagerModules.prompts-kreyren
					homeManagerModules.prompts-starship-kreyren

					# homeManagerModules.kreyren.shells.default
					homeManagerModules.shells-bash-kreyren
					homeManagerModules.shells-nushell-kreyren

					# homeManagerModules.kreyren.system.default
					homeManagerModules.system-dconf-kreyren
					homeManagerModules.system-flatpak-kreyren
					homeManagerModules.system-gtk-kreyren
					homeManagerModules.system-impermanence-kreyren
					homeManagerModules.system-nix-kreyren

					# homeManagerModules.kreyren.terminal-emulators.default
					homeManagerModules.terminal-emulators-alacritty-kreyren

					# homeManagerModules.kreyren.tools.default
					homeManagerModules.tools-direnv-kreyren
					homeManagerModules.tools-git-kreyren
					homeManagerModules.tools-gpg-agent-kreyren

					homeManagerModules.vpn-protonvpn-kreyren

					# homeManagerModules.kreyren.web-browsers.default
					homeManagerModules.web-browsers-firefox-kreyren
					homeManagerModules.web-browsers-librewolf-kreyren

					# GNOME extensions
					homeManagerModules.gext-custom-accent-colors-kreyren
					homeManagerModules.gext-shortcuts-kreyren
				];
			};

			home-manager.extraSpecialArgs = {
				inherit self;

				aagl = self.inputs.aagl.packages."${system}";
				unstable = self.inputs.nixpkgs-unstable.legacyPackages."${system}";
				staging-next = self.inputs.nixpkgs-staging-next.legacyPackages."${system}";
				firefox-addons = self.inputs.firefox-addons.packages."${system}";
			};
		}
	);

	imports = [
		./machines
		./modules
	];
}
