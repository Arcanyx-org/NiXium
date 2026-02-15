{ lib, ... }:

let
	inherit (lib) mkDefault;
in {
	# FIXME-MANAGEMENT(Krey): Move this to global home
	xdg.mimeApps.defaultApplications ={
		# FIXME(Krey): Decide what to do with this, deploy as part of global home firefox module? Flexibility?
		"application/pdf" = mkDefault "firefox.desktop";
	};
}
