{ ... }:

# BinFMT Management of TUPAC

{
	boot.binfmt.emulatedSystems = [
		"aarch64-linux"
		"riscv64-linux"
		"armv7l-linux"
	];

	# Deprioritize QEMU user-mode emulation so cross-arch builds don't starve interactive use
	services.ananicy.extraRules = [
		{ name = "qemu-aarch64"; type = "Heavy_CPU"; }
		{ name = "qemu-arm"; type = "Heavy_CPU"; }
		{ name = "qemu-riscv64"; type = "Heavy_CPU"; }
		{ name = "qemu-aarch64_be"; type = "Heavy_CPU"; }
	];
}
