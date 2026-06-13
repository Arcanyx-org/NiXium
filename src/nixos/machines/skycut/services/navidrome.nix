{ self, config, lib, ... }:

# Mracek-specific configuration of Navidrome

# $ nix-shell -p yt-dlp --run 'yt-dlp --proxy "" -f bestaudio --extract-audio --audio-format opus --audio-quality 256K --output "%(title)s.%(ext)s" --add-metadata --embed-thumbnail URL'

let
	inherit (lib) mkIf;
in mkIf config.services.navidrome.enable {
	services.navidrome.settings.MusicFolder = (if config.boot.impermanence.enable
		then "/nix/persist/system/navidrome"
		else "/var/lib/navidrome/music");

	# systemd.services.create-navidrome-music-dir = {
	# 	enable = true;

	# 	wantedBy = [ "multi-user.target" ];
	# 	after = [ "network.target" ];
	# 	description = "Ensure that navidrome has it's directory for music created and with the correct permissions";
	# 	script = ''
	# 		[ -d "${config.services.navidrome.settings.MusicFolder}" ] || mkdir -p "${config.services.navidrome.settings.MusicFolder}"

	# 		chown navidrome:navidrome "${config.services.navidrome.settings.MusicFolder}"
	# 	'';
	# };

	# Import the private key for an onion service
	age.secrets.mracek-onion-navidrome-private = {
		file = ../secrets/mracek-onion-navidrome-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/navidrome/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	services.tor.relay.onionServices."navidrome" = {
		map = mkIf config.services.tor.enable [{ port = 80; target = { port = config.services.navidrome.settings.Port; }; }];
	};
}
