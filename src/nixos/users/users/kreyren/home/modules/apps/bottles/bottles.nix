{ ... }:

# Kreyren's configuration of Bottles

# FIXME-QA(Krey): Implement this so that it's only applied when bottles are installed
# let
# 	inherit (lib) mkIf;
# in mkIf config.programs.bottles.enable {
{
	dconf.settings = {
		# FIXME(Krey): Maybe these should be options for the programs.bottles.* instead
		"com/usebottles/bottles" = {
			auto-close-bottles = true;
			release-candidate = true;
			experiments-sandbox = true;
			steam-proton-support = true;
		};
	};
}
