{ lib, nixosConfig, ... }:

let
	inherit (lib) mkDefault mkIf;
in mkIf nixosConfig.programs.appimage.enable {
	# Make appimage-run the default handler for AppImage files
	xdg.mimeApps.defaultApplications = {
		"application/vnd.appimage" = mkDefault "appimage-run.desktop";
		"application/x-iso9660-appimage" = mkDefault "appimage-run.desktop";
		"application/x-appimage" = mkDefault "appimage-run.desktop";
	};
}
