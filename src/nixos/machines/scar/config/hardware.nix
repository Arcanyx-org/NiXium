{ lib, pkgs, ... }:

# FIXME-NIXWARE(Krey): Migrate this whole file to NixWare once it's written — it covers bus IDs, graphics acceleration, VAAPI, and EFI access.

# NVIDIA PRIME bus IDs verified from live hardware:
#   lspci | grep -E 'VGA|3D|Display'
#   00:02.0 Intel UHD 630  → PCI:0:2:0  (iGPU, i915 driver)
#   01:00.0 NVIDIA GTX 1060 → PCI:1:0:0 (dGPU, nvidia driver)

let
	inherit (builtins) elem;
	inherit (lib) mkForce optionalString;
	inherit (lib.trivial) release;
in {
	"24.05" = {
		boot.loader.efi.canTouchEfiVariables = true;

		# The option was renamed on `hardware.graphics` in NixOS 24.11+
		hardware.opengl = {
			enable = true;
			driSupport = true;
			driSupport32Bit = true;
		};
	};
	"24.11" = {
		boot.loader.efi.canTouchEfiVariables = true;

		hardware.graphics.enable = true;
		hardware.graphics.enable32Bit = true;

		hardware.nvidia.prime = {
			intelBusId = mkForce "PCI:0:2:0";
			nvidiaBusId = mkForce "PCI:1:0:0";
		};
	};
	"${optionalString (elem release [ "25.05" "25.11" "26.05" ]) release}" = {
		boot.loader.efi.canTouchEfiVariables = true;

		hardware.graphics = {
			enable = true;
			enable32Bit = true;
			# Intel UHD 630 (Coffee Lake GT2) VAAPI drivers. intel-media-driver (iHD) is preferred — supports HEVC, VP9, H.264. intel-vaapi-driver (i965) is fallback — H.264, MPEG-2, VC-1.
			extraPackages = with pkgs; [
				intel-media-driver
				(intel-vaapi-driver.override { enableHybridCodec = true; })
			];
			extraPackages32 = with pkgs.pkgsi686Linux; [
				intel-media-driver
				(intel-vaapi-driver.override { enableHybridCodec = true; })
			];
		};

		environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
		environment.systemPackages = with pkgs; [ libva-utils ];

		hardware.nvidia.prime = {
			intelBusId = mkForce "PCI:0:2:0";
			nvidiaBusId = mkForce "PCI:1:0:0";
		};
	};
}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")
