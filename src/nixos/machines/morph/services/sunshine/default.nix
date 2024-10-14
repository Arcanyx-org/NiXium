{ self, pkgs, config, lib, aagl, ... }:

# MORPH-specific configuration of Sunshine

let
	inherit (lib) mkIf;
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture

	services.sunshine.openFirewall = true; # Open Firewall for local network

	# Create the session
		# Set Up The Sunshine User
		users.users.sunshine = {
			description = "Sunshine User";
			# uid = 1000; # Do we care for declarative UID for this user?
			# password = "000000";
			isNormalUser = true;
			createHome = true;
			extraGroups = [
				"video" # Allow access to the video devices e.g. GPU
			];
			packages = [
				self.inputs.aagl.packages.x86_64-linux.anime-game-launcher
			];
		};
		# Enable Auto-Login
		services.displayManager.autoLogin.enable = true;
		services.displayManager.autoLogin.user = "sunshine";

	# Desktop Environment - Kodi
	services.xserver.enable = true;
	services.xserver.desktopManager.kodi.enable = true;
	services.xserver.displayManager.lightdm.greeter.enable = false;
		# Plugins
		services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [
			# osmc-skin
			# sponsorblock
			# youtube
			(pkgs.kodi.packages.buildKodiAddon rec {
				pname = "akl";
				namespace = "plugin.program.akl";
				version = "1.5.1";

				src = pkgs.fetchzip {
					url = "https://github.com/chrisism/repository.chrisism.dev/raw/refs/heads/main/matrix/plugin.program.akl/plugin.program.akl-1.5.1.zip";
					hash = "sha256-RK+DHt5LxGMPHV3i3HEZ8PSe7ukIa3wlN2yzuZnj/tc=";
				};

				propagatedBuildInputs = with pkgs.kodi.packages; [
					xbmcswift2
					routing
					# (pkgs.kodi.packages.buildKodiAddon rec {
					# 	pname = "akl.scripts";
					# 	namespace = "script.module.akl";
					# 	version = "1.1.2";

					# 	src = pkgs.fetchzip {
					# 		url = "https://github.com/chrisism/repository.chrisism.dev/raw/refs/heads/main/matrix/script.module.akl/script.module.akl-1.1.2.zip";
					# 		hash = "sha256-lS04rfGBgr+42JBkw1TKIfwI5x1MKHA2/9/r42yqSwY=";
					# 	};

					# 	propagatedBuildInputs = with pkgs.kodi.packages; [
					# 		xbmcswift2
					# 		routing
					# 		requests
					# 	];

					# 	passthru = {
					# 		pythonPath = "lib";
					# 	};

					# 	meta = with lib; {
					# 		homepage = "https://github.com/chrisism/repository.chrisism.dev/blob/main/matrix/plugin.program.akl";
					# 		description = "Advanced Kodi Launcher";
					# 		# maintainers = teams.kodi.members;
					# 	};
					# })
				];

				passthru = {
					pythonPath = "resources/lib";
				};

				meta = with lib; {
					homepage = "https://github.com/chrisism/repository.chrisism.dev/blob/main/matrix/plugin.program.akl";
					description = "Advanced Kodi Launcher";
					# maintainers = teams.kodi.members;
				};
			})
		]);

	# Tor Access to The Web UI
	services.tor.relay.onionServices."sunshine".map = mkIf config.services.tor.enable [{ port = 80; target = { port = 47990; }; }]; # Provide the admin panel over onions to make it accessible

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
