{ pkgs, ... }:

# Generic Management of the GTK Applications

{
	gtk = {
		theme = {
			name = "Adw-gtk3-dark";
			package = pkgs.adw-gtk3;
		};

		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = "0";
		};

		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = "0";
		};
	};
}
