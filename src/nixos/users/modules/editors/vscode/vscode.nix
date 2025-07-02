{ config, lib, pkgs, ... }:

let
	inherit (lib) mkDefault mkIf mkMerge;
in mkIf config.programs.vscode.enable (mkMerge [
	{
		"24.11" = {
			programs.vscode = {
				package = mkDefault pkgs.vscodium; # Always prefer vscodium over vscode

				# Purity Enforcement
				enableExtensionUpdateCheck = false;
				enableUpdateCheck = false;

				# Extensions to install by default, can be overwritten by the user
				extensions = with pkgs.vscode-extensions; [
					editorconfig.editorconfig
					mkhl.direnv
					jnoortheen.nix-ide
					oderwat.indent-rainbow
					# FIXME(Krey): Needs to be packages
					#edwinhuish.better-comments-next
				];
				userSettings = {
					"editor.mouseWheelZoom" = true; # Zoom with mouse wheel
					"editor.renderWhitespace" = "all"; # Highlight invisible characters
				};
			};
		};
		"25.05" = {
			# `programs.vscode.extensions` (24.11) -> `programs.vscode.profiles.default.extensions` (25.05)
			# `programs.vscode.enableExtensionUpdateCheck` (24.11) -> `programs.vscode.profiles.default.enableExtensionUpdateCheck` (25.05)
			programs.vscode = {
				package = mkDefault pkgs.vscodium; # Always prefer vscodium over vscode

				# Extensions to install by default, can be overwritten by the user
				profiles.default = {
					# Purity Enforcement
						enableExtensionUpdateCheck = false;
						enableUpdateCheck = false;

					extensions = with pkgs.vscode-extensions; [
						editorconfig.editorconfig
						mkhl.direnv
						jnoortheen.nix-ide
						oderwat.indent-rainbow
						# FIXME(Krey): Needs to be packages
						#edwinhuish.better-comments-next
					];
					userSettings = {
						"editor.mouseWheelZoom" = true; # Zoom with mouse wheel
						"editor.renderWhitespace" = "all"; # Highlight invisible characters
					};
				};
			};
		};
	}."${lib.trivial.release}" or (throw "FIXME: NiXium's Home vscode management doesn't include this release: ${lib.trivial.release}")
])
