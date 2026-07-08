{ config, pkgs, self, ... }:

{
	age.secrets.kreyren-wireproxy-protonvpn-config = {
		file = "${self.outPath}/src/nixos/users/users/kreyren/home/secrets/kreyren-wireproxy-protonvpn-config.age";
	};

	# FIXME(Krey): Make an option for this
	systemd.user.services.wireproxy-protonvpn = {
		Unit = {
			Description = "wireproxy protonvpn initialization";
			After = [ "agenix.service" ];
		};
		Service = {
			Type = "exec";
			ExecStart = "${pkgs.wireproxy}/bin/wireproxy --config ${config.age.secrets.kreyren-wireproxy-protonvpn-config.path}";
			Restart = "on-failure";
		};
		Install.WantedBy = [ "default.target" ];
	};
}
