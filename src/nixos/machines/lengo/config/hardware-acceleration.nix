{ lib, pkgs, ... }:

# Hardware-acceleration management of LENGO

# APU: AMD Z1 Extreme

let
	inherit (lib) mkMerge;
in mkMerge [
	{
		"24.05" = {
			# The option was renamed on `hardware.graphics` in NixOS 24.11+
			hardware.opengl = {
				enable = true;
				driSupport = true;
				driSupport32Bit = true;
			};

			# AMDVLK
			hardware.opengl.extraPackages = with pkgs; [
				amdvlk
			];
			# For 32 bit applications
			hardware.opengl.extraPackages32 = with pkgs; [
				driversi686Linux.amdvlk
			];
		};

		"24.11" = {
			hardware.graphics.enable = true;
			hardware.graphics.enable32Bit = true;

			# AMDVLK
			hardware.graphics.extraPackages = with pkgs; [
				amdvlk
			];
			# For 32 bit applications
			hardware.graphics.extraPackages32 = with pkgs; [
				driversi686Linux.amdvlk
			];
		};

		# FIXME-QA(Krey): Duplicate Code
		"25.05" = {
			hardware.graphics.enable = true;
			hardware.graphics.enable32Bit = true;

			# AMDVLK
			hardware.graphics.extraPackages = with pkgs; [
				amdvlk
			];
			# For 32 bit applications
			hardware.graphics.extraPackages32 = with pkgs; [
				driversi686Linux.amdvlk
			];
		};
	}."${lib.trivial.release}" or (throw "Release not implemented: ${lib.trivial.release}")
]
