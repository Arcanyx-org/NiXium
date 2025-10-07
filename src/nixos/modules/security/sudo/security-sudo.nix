{ config, lib, ...}:

# Security Management of sudo

let
	inherit (lib) mkIf mkMerge;
in mkMerge [
	( mkIf config.security.sudo.enable {
	security.sudo.extraConfig = "Defaults !lecture"; # Rollback results in sudo lectures after each reboot
	})

	( mkIf config.security.sudo-rs.enable {
	security.sudo-rs.extraConfig = "Defaults !lecture"; # Rollback results in sudo lectures after each reboot
	})
]
