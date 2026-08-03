# FIXME-VM(Krey): This module cannot be tested in a VM — the wireproxy config
# is an age-encrypted secret (kira-wireproxy-protonvpn-config.age) encrypted to
# real-machine identities. The VM has no decryption identity, so age activation
# fails. Same precedent as apps/opencode (kreyren).
{
	flake.homeManagerModules.vpn-protonvpn-kira = ./protonvpn-kira.nix;
}
