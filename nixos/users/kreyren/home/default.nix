{ moduleWithSystem, config, self, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.kreyren = moduleWithSystem (
		perSystem@{ system }:
		{ ... }:
		{
			imports = [{
				home-manager.users.kreyren = {
					imports = [
						self.inputs.arkenfox.hmModules.default

						./home.nix

						# FIXME-QA(Krey): Expected to be just `homeManagerModules.editors-kreyren` same for all others..
						homeManagerModules.apps-flameshot-kreyren

						homeManagerModules.editors-vim-kreyren
						homeManagerModules.editors-vscode-kreyren

						#homeManagerModules.prompts-kreyren
						homeManagerModules.prompts-starship-kreyren

						# homeManagerModules.kreyren.shells.default
						homeManagerModules.shells-bash-kreyren
						homeManagerModules.shells-nushell-kreyren

						# homeManagerModules.kreyren.system.default
						homeManagerModules.system-dconf-kreyren
						homeManagerModules.system-gtk-kreyren

						# homeManagerModules.kreyren.terminal-emulators.default
						homeManagerModules.terminal-emulators-alacritty-kreyren

						# homeManagerModules.kreyren.tools.default
						homeManagerModules.tools-direnv-kreyren
						homeManagerModules.tools-git-kreyren
						homeManagerModules.tools-gpg-agent-kreyren

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
					unstable = self.inputs.nixpkgs-unstable.legacyPackages."${system}";
					firefox-addons = self.inputs.firefox-addons.packages."${system}";
				};
			}];
		}
	);

	imports = [
		./machines
		./modules
	];
}
