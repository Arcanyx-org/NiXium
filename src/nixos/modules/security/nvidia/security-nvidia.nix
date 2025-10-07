{ config, lib, ... }:

# Global Security Management of Nvidia

let
	inherit (lib) mkIf mkForce mkMerge;
in mkMerge [
	#! Patches for critical vulnerabilities in the proprietary Nvidia Driver version 535.154, refer to https://discourse.nixos.org/t/all-nividia-drivers-crash-or-do-not-work/47427/7 for details
	#!
	#! Management for:
	#! * CVE‑2024‑0090
	#! * CVE‑2024‑0091
	#! * CVE‑2024‑0093
	#! * CVE‑2024‑0092
	#! * CVE‑2024‑0099
	#! * CVE‑2024‑0084
	#! * CVE‑2024‑0085
	#! * CVE‑2024‑0094
	#! * CVE‑2024‑0086
	#!
	#! Discussed in https://github.com/NiXium-org/NiXium/issues/3
	(mkIf (config.boot.kernelPackages.nvidiaPackages.production.version == "535.154") {
		hardware.nvidia = {
			# This is the latest driver with the CVE patches + explicit sync
			package = mkForce config.boot.kernelPackages.nvidiaPackages.mkDriver {
				version = "555.52.04";
				sha256_64bit = "sha256-nVOubb7zKulXhux9AruUTVBQwccFFuYGWrU1ZiakRAI=";
				sha256_aarch64 = "sha256-Kt60kTTO3mli66De2d1CAoE3wr0yUbBe7eqCIrYHcWk=";
				openSha256 = "sha256-wDimW8/rJlmwr1zQz8+b1uvxxxbOf3Bpk060lfLKuy0=";
				settingsSha256 = "sha256-PMh5efbSEq7iqEMBr2+VGQYkBG73TGUh6FuDHZhmwHk=";
				persistencedSha256 = "sha256-KAYIvPjUVilQQcD04h163MHmKcQrn2a8oaXujL2Bxro=";
			};
		};
	})

	{
		# Outsource the decision to whether we want to use the nvidia's open-source driver on Nixpkgs
		# FIXME(Krey): I want to illustrate this better like `hardware.nvidia.open = nixpkgs.config..stuff`
		# hardware.nvidia.open
	}
]
