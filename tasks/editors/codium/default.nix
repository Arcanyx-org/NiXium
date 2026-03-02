{ inputs, ... }:

{
	perSystem = { system, lib, pkgs, ... }: {
		mission-control.scripts = {
			codium = {
				description = "Open repository-standardized VSCodium with configuration extensions for development";
				category = "Integrated Development Environments";
				exec = let
					vscodium-with-extensions = pkgs.vscode-with-extensions.override {
						vscode = pkgs.vscodium;
						vscodeExtensions = let
								open-vsx-release = inputs.nix-vscode-extensions.extensions.${system}.open-vsx-release;
							in [
							open-vsx-release.jnoortheen.nix-ide
							open-vsx-release.arrterian.nix-env-selector
							open-vsx-release.aaron-bond.better-comments
							open-vsx-release.mkhl.direnv
							open-vsx-release.editorconfig.editorconfig
							open-vsx-release.pkief.material-icon-theme
							open-vsx-release.timonwong.shellcheck
							open-vsx-release.eamodio.gitlens
							open-vsx-release.gruntfuggly.todo-tree
							open-vsx-release.oderwat.indent-rainbow
							open-vsx-release.medo64.render-crlf
							open-vsx-release.markwylde.vscode-filesize
							open-vsx-release.anwar.resourcemonitor
							open-vsx-release.sst-dev.opencode
						];
					};
				in ''${vscodium-with-extensions}/bin/codium "$FLAKE_ROOT/default.code-workspace"'';
			};
		};
	};
}
