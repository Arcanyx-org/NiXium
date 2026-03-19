{
	# FIXME-QA(Krey): Module and directory name "impermenance" is a typo of "impermanence"; renaming requires a migration plan (see DISCUSSION.md)
	flake.nixosModules.system-impermenance = ./system-impermenance.nix;
}
