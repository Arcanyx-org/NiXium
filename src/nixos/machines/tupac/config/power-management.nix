{ config, lib, pkgs, ... }:

#! # Power Management of TUPAC
#!
#! Test Script:
#!     $ echo "$(($(cat /sys/class/power_supply/BAT0/voltage_now) / 1000000 * $(cat /sys/class/power_supply/BAT0/current_now) / 1000000))"
#!
#! Credit:
#! * https://gist.github.com/polamjag/a76f34a4991b35f9434a

# This doesn't seem to change anything?
			# * https://forums.gentoo.org/viewtopic-t-1068292-start-0.html

# NOTE(Krey): Disabling cores on BAT seems to not be productive and leads to higher power consumption

# Try  using pcie_aspm=force in kernel cli

# sudo modprobe -r intel_powerclamp -- This module might be causing bad power efficiency

# cat /sys/class/nvme/nvme0/power/runtime_status reports unsupported, unsure how to enable

let
	inherit (lib) mkIf mkMerge optionalString elem;
	inherit (lib.trivial) release;
in mkIf config.powerManagement.enable (mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = {
			services.logind = {
				powerKey = "suspend-then-hibernate";
				powerKeyLongPress = "poweroff";
			};
		};

		"${optionalString (elem release [ "25.11" "26.05" ]) release}" = {
			services.logind.settings.Login = {
				HandlePowerKey = "suspend-then-hibernate";
				HandlePowerKeyLongPress = "poweroff";
				HandleLidSwitch = "suspend-then-hibernate";
				HandleLidSwitchExternalPower = "suspend";
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		powerManagement.powertop.enable = true;
		systemd.sleep.settings.Sleep.HibernateDelaySec = "30s";
	}

	# TLP Management
	(mkIf (config.services.tlp.enable == true) {
		services.tlp.settings = {
			TLP_ENABLE = 1; # Use TLP

			# Platform Profiles
			PLATFORM_PROFILE_ON_AC = "performance";
			PLATFORM_PROFILE_ON_BAT = "low-power";

			# Set Governors depending on power input
			CPU_SCALING_GOVERNOR_ON_AC = "performance"; # AC power
			CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; # BATTERY power

			# Whether to use boost depending on power input
			CPU_BOOST_ON_AC = 1;
			CPU_BOOST_ON_BAT = 0;

			# Energy Profile Policy
			CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
			CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

			CPU_DRIVER_OPMODE_ON_AC = "active";
			CPU_DRIVER_OPMODE_ON_BAT = "passive";

			# CPU Performance Scaling
			CPU_MAX_PERF_ON_AC = 100;
			CPU_MIN_PERF_ON_AC = 0;

			CPU_MAX_PERF_ON_BAT = 20;
			CPU_MIN_PERF_ON_BAT = 0;

			# HWP
			CPU_HWP_DYN_BOOST_ON_AC = 1;
			CPU_HWP_DYN_BOOST_ON_BAT = 0;

			# Intel GPU
			INTEL_GPU_MIN_FREQ_ON_AC = 100; # MHz
			INTEL_GPU_MIN_FREQ_ON_BAT = 100; # MHz
			INTEL_GPU_MAX_FREQ_ON_AC = 1400; # MHz
			INTEL_GPU_MAX_FREQ_ON_BAT = 1400; # MHZ
			INTEL_GPU_BOOST_FREQ_ON_AC = 1400; # MHZ
			INTEL_GPU_BOOST_FREQ_ON_BAT = 1400; # MHZ

			# RAM
			MEM_SLEEP_ON_AC = "s2idle";
			MEM_SLEEP_ON_BAT = "deep";

			# SATA aggressive link power management (ALPM):
			# min_power/medium_power/max_performance
			SATA_LINKPWR_ON_AC = "max_performance";
			SATA_LINKPWR_ON_BAT	=	"min_power";

			# PCI Express Active State Power Management (PCIe ASPM):
			# default/performance/powersave
			# Hint: needs kernel boot option pcie_aspm=force on some machines
			PCIE_ASPM_ON_AC = "performance";
			PCIE_ASPM_ON_BAT = "powersave";

			# WiFi power saving mode: 1=disable/5=enable
			WIFI_PWR_ON_AC = 1;
			WIFI_PWR_ON_BAT = 5;

			# Runtime Power Management for pci(e) bus devices
			RUNTIME_PM_ON_AC = "on";
			RUNTIME_PM_ON_BAT = "auto";

			# Battery
			START_CHARGE_THRESH_BAT0 = 0;
			STOP_CHARGE_THRESH_BAT0 = 100;
		};
	})

	{
		# Ananicy - Auto-Nice Management
		services.ananicy = {
			enable = true;
			package = pkgs.ananicy-cpp;
			rulesProvider = pkgs.ananicy-rules-cachyos;

			# Custom types for tupac-specific workloads not covered by cachyos rules
			extraTypes = [
				# AI/ML inference — responsive but doesn't starve interactive apps
				{ type = "LLM-Inference"; nice = -5; ioclass = "best-effort"; ionice = 4; }
				# Streaming servers — low latency encoding for VR/game streaming
				{ type = "Streaming-Server"; nice = -8; ioclass = "best-effort"; ionice = 2; }
			];
		};
	}
])
