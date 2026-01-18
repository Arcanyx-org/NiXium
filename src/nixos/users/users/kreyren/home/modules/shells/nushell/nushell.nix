{ lib, config, ... }:

# Generic Nushell Configuration

let
	inherit (lib) mkIf;
in mkIf config.programs.nushell.enable {
	programs.nushell = {
		extraConfig = ''
			# FIXME(Krey): Customize from example https://github.com/nushell/nushell/blob/main/crates/nu-utils/src/sample_config/default_config.nu
			$env.config = {
				show_banner: false,

				rm: {
					# Always move files in trash
					always_trash: true,
				}
			}
		'';
	};

	programs.starship.enableNushellIntegration = mkIf config.programs.nushell.enable;
}
