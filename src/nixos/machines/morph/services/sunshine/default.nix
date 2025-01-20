{ self, pkgs, config, lib, aagl, ... }:

# MORPH-specific configuration of Sunshine

let
	inherit (lib) mkIf;

	akl-scripts = pkgs.kodi.packages.buildKodiAddon rec {
		pname = "akl.scripts";
		namespace = "script.module.akl";
		version = "1.1.2";

		src = pkgs.fetchzip {
			url = "https://github.com/chrisism/repository.chrisism.dev/raw/refs/heads/main/matrix/script.module.akl/script.module.akl-1.1.2.zip";
			hash = "sha256-lS04rfGBgr+42JBkw1TKIfwI5x1MKHA2/9/r42yqSwY=";
		};

		propagatedBuildInputs = with pkgs.kodi.packages; [
			six
			xbmcswift2
			routing
			requests
		];

		passthru = {
			pythonPath = "lib";
		};

		meta = with lib; {
			homepage = "https://github.com/chrisism/repository.chrisism.dev/blob/main/matrix/plugin.program.akl";
			description = "Advanced Kodi Launcher";
			# maintainers = teams.kodi.members;
		};
	};

	# FIXME(Krey): Requires resources/scheme.sql installed in $USER/.kodi/addons/plugins.program.aki/resources/scheme.sql otherwise the addon will fail to deploy
	akl = pkgs.kodi.packages.buildKodiAddon rec {
		pname = "akl";
		namespace = "plugin.program.akl";
		version = "1.5.1";

		src = pkgs.fetchzip {
			url = "https://github.com/chrisism/repository.chrisism.dev/raw/refs/heads/main/matrix/plugin.program.akl/plugin.program.akl-1.5.1.zip";
			hash = "sha256-RK+DHt5LxGMPHV3i3HEZ8PSe7ukIa3wlN2yzuZnj/tc=";
		};

		propagatedBuildInputs = with pkgs.kodi.packages; [
			six
			xbmcswift2
			routing
			akl-scripts
		];

		passthru = {
			pythonPath = "resources/lib";
		};

		meta = with lib; {
			homepage = "https://github.com/chrisism/repository.chrisism.dev/blob/main/matrix/plugin.program.akl";
			description = "Advanced Kodi Launcher";
			# maintainers = teams.kodi.members;
		};
	};
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture

	services.sunshine.openFirewall = true; # Open Firewall for local network

	# Enable Auto-Login
	# FIXME-SECURITY(Krey): Require that the user is logged-in and out remotely
	services.displayManager.autoLogin.enable = true;
	services.displayManager.autoLogin.user = "kreyren";

	# Desktop Environment - Kodi
		# FIXME(Krey): Struggling to figure out a way to add and play linux games through kodi rn
		# services.xserver.enable = true;
		# services.xserver.desktopManager.kodi.enable = true;
		# services.xserver.displayManager.lightdm.greeter.enable = false;
		# 	# System-wide plugins - https://github.com/NixOS/nixpkgs/tree/nixos-24.05/pkgs/applications/video/kodi/addons
		# 	services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [
		# 		# osmc-skin
		# 		# sponsorblock
		# 		# youtube
		# 		# akl
		# 		# akl-scripts
		# 	]);

	# Desktop Environment - GNOME (Backup UI)
	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
		programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)

	# Tor Access to The Web UI
	services.tor.relay.onionServices."sunshine".map = mkIf config.services.tor.enable [{ port = 80; target = { port = 47990; }; }]; # Provide the admin panel over onions to make it accessible

	# Broadcasted Applications
	services.sunshine.applications = {
		apps = [
			{
				name = "Desktop";
				image-path =  "desktop.png";
			}
			{
				name = "That Anime Game";
				image-path = "${./images/sunshine-aagl-cover.png}";
				# FIXME-QA(Krey): This doesn't work to open the anime-game
				detached = [ "${self.inputs.aagl.packages.x86_64-linux.anime-game-launcher}/bin/anime-game-launcher" ];
			}
			{
				# DNM(Krey): For Testing..
				name = "Alacritty";
				image-path = "desktop.png";
				detached = [ "${pkgs.alacritty}/bin/alacritty" ];
			}
		];
	};

	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		"/home/sunshine/.local/share/anime-game-launcher"
	];
}
