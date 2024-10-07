{ self, pkgs, config, lib, aagl, ... }:

# MORPH-specific configuration of Sunshine

let
	inherit (lib) mkIf;
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture

	services.sunshine.openFirewall = true; # Open Firewall for local network

	# Declare the expected applications
	services.sunshine.applications = {
		apps = [
			{
				name = "Desktop";
				image-path =  "desktop.png";
			}
			{
				name = "Genshin Impact";
				image-path = "${./images/sunshine-aagl-cover.png}";
				# FIXME-QA(Krey): This doesn't work to open the anime-game
				detached = [ "${self.inputs.aagl.packages.x86_64-linux.anime-game-launcher}/bin/anime-game-launcher" ];
			}
			{
				name = "Alacritty";
				image-path = "desktop.png";
				detached = [ "${pkgs.alacritty}/bin/alacritty" ];
			}
		];
	};

	# User used for the session
	users.users.sunshine = {
		description = "Sunshine User";
		# uid = 1000; # Do we care for declarative UID for this user?
		isNormalUser = true;
		createHome = true;
		extraGroups = [
			"video" # Allow access to the video devices e.g. GPU
		];
		packages = [
			self.inputs.aagl.packages.x86_64-linux.anime-game-launcher
		];
	};
	services.displayManager.autoLogin.enable = true;
	services.displayManager.autoLogin.user = "sunshine";

	services.tor.relay.onionServices."sunshine".map = mkIf config.services.tor.enable [{ port = 80; target = { port = 47990; }; }]; # Provide the admin panel over onions to make it accessible

	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;

	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		"/home/sunshine/.local/share/anime-game-launcher"
	];
}
