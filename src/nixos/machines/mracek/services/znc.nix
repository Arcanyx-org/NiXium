{ self, config, lib, ... }:

# Mracek-specific configuration of ZNC, mainly personal use by Kreyren

let
	inherit (lib) mkIf;
in mkIf config.services.znc.enable {
	services.znc.mutable = false; # Whether the admin user is allowed to change settings in the web UI
	services.znc.confOptions.nick = "kreyren";

	services.znc.confOptions.networks = {
		"libera" = {
			server = "libera75jm6of4wxpxt4aynol3xjmbtxgfyjpu34ss4d7r7q2v5zrpyd.onion";
			port = 6697;
			useSSL = true;
			channels = [
				"armbian"
				"base48"
				"kicad"
			];
		};
		"OFTC" = {
			server = "oftcnet6xg6roj6d7id4y4cu6dchysacqj2ldgea73qzdagufflqxrid.onion";
			port = 6667;
			useSSL = false;
			channels = [
				"sunxi-linux"
			];
		};
	};
}
