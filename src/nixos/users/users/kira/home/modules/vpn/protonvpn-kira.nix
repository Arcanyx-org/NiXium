{ pkgs, lib, config, ... }:

let
	inherit (lib) mkIf;
in {
	age.secrets.kira-wireproxy-protonvpn-config.file = ./kira-wireproxy-protonvpn-config.age;

	# FIXME(Krey): Make an option for this
	systemd.user.services.wireproxy-protonvpn = {
		Unit = {
			Description = "wireproxy protonvpn initialization";
			After = [ "agenix.service" ];
		};
		Service = {
			Type = "exec";
			ExecStart = "${pkgs.wireproxy}/bin/wireproxy --config /run/user/1001/agenix/kira-wireproxy-protonvpn-config";
			Restart = "on-failure";
		};
		Install.WantedBy = [ "default.target" ];
	};
}
