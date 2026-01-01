{ config, lib,... }:

#! # Power Management of MRACEK
#! To optimize the system of it's role of always-on control server it's desirable to get it as power efficient as possible as it's designed to always do tasks at idle state unless something unexpected happened for the client to request remote build or processing of instructions for which it should be able to boost to process the critical tasks.

let
	inherit (lib) mkIf;
in mkIf config.powerManagement.enable {
	boot.blacklistedKernelModules = [
		"backlight" # Eats constantly ~1W of power even with lid closed and display turned off
		"realtek" # Eats ~0.40 W
		"asus-nb-wmi" # Eats ~0.30 W
		"spi_intel" # Eats ~0.30 W
	];

	powerManagement.powertop.enable = true;

	services.logind.lidSwitch = "lock"; # Do not suspend on lid close event
	services.logind.lidSwitchExternalPower = "lock"; # Lock the system on closing the lid when on external power instead of suspend/hibernation

	services.thermald.enable = true; # Use the temperature management daemon

	services.auto-cpufreq.enable = true; # Use auto-cpufreq
	# https://github.com/AdnanHodzic/auto-cpufreq/blob/v1.9.9/auto-cpufreq.conf-example
	services.auto-cpufreq.settings = {
		charger = {
			governor = "powersave";

			scaling_min_freq = 800000; # 800 MHz = 800000 kHz --> scaling_min_freq = 800000

			# FIXME-OPTIMIZATION(Krey): Figure out what max frequency we want here
			scaling_max_freq = 1000000; # 1GHz = 1000 MHz = 1000000 kHz -> scaling_max_freq = 1000000

			# Mracek might be used for critical tasks as a backup processing system in case the designated system is unreachable so allow it to do turbo
			turbo = "auto";
		};

		# Mracek should never get to a state where it's running off of a battery as the battery is there only for emergency scenarios where the power is lost and in that case it should be set into a super-power efficient mode
		battery = {
			governor = "powersave";

			# 800 MHz seems to be the most stable to make the BIOS to not fail-safe the system
			scaling_min_freq = 800000; # 800 MHz = 800000 kHz --> scaling_min_freq = 800000
			scaling_max_freq = 800000; # 800 MHz = 800000 kHz --> scaling_min_freq = 800000

			turbo = "never";
		};
	};

	# FIXME-QA(Krey): Figure out what to do here
	# powerManagement = {
	# 	# driver: intel_pstate
	# 	cpuFreqGovernor = "powersave"; # Don't be so aggressive with the CPU scheduling
	# 	# cpufreq = {
	# 	# 	min = 800000; # Minimal CPU frequency e.g.   800000 = 800 kHz
	# 	# 	max = 1000000; # Maximal CPU frequency e.g. 2200000 = 2.2 GHz
	# 	# };
	# 	# scsiLinkPolicy = "min_power"; # SCSI link power management policy
	# };
}
