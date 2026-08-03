# FIXME-VM(Krey): Not possible to test in VM — the module includes an age
# secret (kreyren-github-access-token) which is not decryptable in VMs (no
# ragenix identity). See the apps/opencode deferral for the same reason.
{
	flake.homeManagerModules.system-nix-kreyren = ./nix.nix;
}
