{ ... }:

#! # BinFMT Management of MRACEK
#! Mracek is a used to send instructions to other systems in the infrastructure which may not share the same infrastructure which creates problems where the nix daemon is unable to process these instructions without binFMT enabled. As such it should always have all architectures added to be able to process them

{
	boot.binfmt.emulatedSystems = [
		"aarch64-linux"
		"riscv64-linux"
		"armv7l-linux"
	];
}