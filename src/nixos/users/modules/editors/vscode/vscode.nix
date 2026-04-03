{ config, lib, pkgs, ... }:

let
	inherit (lib) elem optionalString mkDefault mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf config.programs.vscode.enable (mkMerge [
	{
		"24.11" = {
			programs.vscode = {
				package = mkDefault pkgs.vscodium; # Always prefer VSCodium (telemetry-free) over upstream VSCode

				# Purity enforcement — disable auto-update checks so the package
				# manager (Nix) remains the sole source of truth for installed extensions
				enableExtensionUpdateCheck = false;
				enableUpdateCheck = false;

				# Extensions installed by default for all users; individual user
				# modules may extend this list via mkMerge
				extensions = with pkgs.vscode-extensions; [
					editorconfig.editorconfig  # Honour .editorconfig files for consistent whitespace across editors
					mkhl.direnv                # Load direnv environments automatically when opening a project
					jnoortheen.nix-ide         # Nix language support (syntax, LSP integration via nil/nixd)
					oderwat.indent-rainbow     # Colorize indentation levels for at-a-glance depth perception
					# FIXME(Krey): Needs to be packages
					#edwinhuish.better-comments-next
				];
				userSettings = {
					"editor.mouseWheelZoom" = true;       # Zoom with mouse wheel
					"editor.renderWhitespace" = "all";    # Highlight invisible characters so whitespace issues are spotted immediately
				};
			};
		};
		"${optionalString (elem release [ "25.05" "25.11" ]) release}" = {
			# `programs.vscode.extensions` (24.11) -> `programs.vscode.profiles.default.extensions` (25.05)
			# `programs.vscode.enableExtensionUpdateCheck` (24.11) -> `programs.vscode.profiles.default.enableExtensionUpdateCheck` (25.05)
			programs.vscode = {
				package = mkDefault pkgs.vscodium; # Always prefer VSCodium (telemetry-free) over upstream VSCode

				# Extensions installed by default for all users; individual user
				# modules may extend this list via mkMerge
				profiles.default = {
					# Purity enforcement — disable auto-update checks so the package
					# manager (Nix) remains the sole source of truth for installed extensions
					enableExtensionUpdateCheck = false;
					enableUpdateCheck = false;

					extensions = with pkgs.vscode-extensions; [
						editorconfig.editorconfig  # Honour .editorconfig files for consistent whitespace across editors
						mkhl.direnv                # Load direnv environments automatically when opening a project
						jnoortheen.nix-ide         # Nix language support (syntax, LSP integration via nil/nixd)
						oderwat.indent-rainbow     # Colorize indentation levels for at-a-glance depth perception
						# FIXME(Krey): Needs to be packages
						#edwinhuish.better-comments-next
					];
					userSettings = {
						"editor.mouseWheelZoom" = true;       # Zoom with mouse wheel
						"editor.renderWhitespace" = "all";    # Highlight invisible characters so whitespace issues are spotted immediately
					};
				};
			};
		};
	}."${release}"
])
