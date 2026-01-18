{ config, lib, ... }:

let
	inherit (lib) mkIf;
in mkIf config.services.gpg-agent.enable {
	services.gpg-agent = {
		# Needed for public key auth to SSH
		enableSshSupport = true;
	};
}
