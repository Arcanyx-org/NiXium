{ config, lib, pkgs, nixpkgs, ... }:

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf config.programs.vscode.enable (mkMerge [
	{
		"24.11" = {
			programs.vscode = {
				package = pkgs.vscodium;
				extensions = with pkgs.vscode-extensions; [
					editorconfig.editorconfig
					mkhl.direnv
					oderwat.indent-rainbow # Colorize indentation levels to aid navigation in deeply nested files
				];
				userSettings = {
					# Zoom with mouse wheel
					"editor.mouseWheelZoom" = true;

					# Highlight invisible characters
					"editor.renderWhitespace" = "all";

					"window.zoomLevel" = -1;

					"workbench.colorTheme" = "Abyss"; # Set Theme

					"window.newWindowDimensions" = "fullscreen";

					# To make the built-in web browser in vscodium to work
					"browse-lite.chromeExecutable" = "${pkgs.ungoogled-chromium}/bin/chromium";

					"http.proxy" = "socks5://127.0.0.1:25344"; # Use ProtonVPN for VSCodium
				};
			};
		};
		"${optionalString (elem release [ "25.05" "25.11" ]) release}" = {
			# `programs.vscode.extensions` (24.11) -> `programs.vscode.profiles.default.extensions` (25.05)
			programs.vscode = {
				package = pkgs.vscodium;
				profiles.default = {
				extensions = with pkgs.vscode-extensions; [
					editorconfig.editorconfig
					mkhl.direnv
					oderwat.indent-rainbow # Colorize indentation levels to aid navigation in deeply nested files
				];
					userSettings = {
						# Zoom with mouse wheel
						"editor.mouseWheelZoom" = true;

						# Highlight invisible characters
						"editor.renderWhitespace" = "all";

						"window.zoomLevel" = -1;

						"workbench.colorTheme" = "Abyss"; # Set Theme

						"window.newWindowDimensions" = "fullscreen";

						# To make the built-in web browser in vscodium to work
						"browse-lite.chromeExecutable" = "${pkgs.ungoogled-chromium}/bin/chromium";

						"http.proxy" = "socks5://127.0.0.1:9050"; # Use System Tor for VSCodium

						# Privy
							"privy.autocomplete.model" = "starcoder2:7b";
							"privy.model" = "custom";
							"privy.customModel" = "codellama:7b-instruct";
							"privy.indexRepository.enabled" = true;
					};
				};
			};
		};
	}."${release}"
])
