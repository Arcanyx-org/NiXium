{ config, lib, ... }:

# Thermal Management of TUPAC
#
# The Tulpar T5 V23.2 is designed for liquid metal thermal interface material from the factory
# but was found to have Arctic MX4 thermal paste instead. MX4 has ~4x lower
# thermal conductivity than liquid metal (~8.5 W/mK vs ~73 W/mK), which is
# insufficient for the i7-12700H's thermal output under full load.
#
# Without this module, the CPU hits Tj_max (100°C) within seconds of full
# load on all 16 cores (6P+8E), triggering aggressive thermal throttling
# and causing severe performance instability.
#
# This module enforces an 80°C thermal ceiling via intel_pstate's max_perf_pct
# knob, which limits the maximum P-state (frequency × voltage) the hardware
# can reach. It also enables thermald as a safety net for transient spikes.
#
# Test data (30s stress-ng --cpu $(nproc), x86_pkg_temp sensor):
#
# | max_perf_pct | Peak Temp | Perf (bogo/s) | vs Baseline |
# |--------------|-----------|---------------|-------------|
# | 100 (default)| 96-100°C  | 1280          | 100%        |
# | 85           | 95-100°C  | 1286          | 100%        |
# | 75           | 95-100°C  | 1274          |  99%        |
# | 60           | 74-81°C   |  976          |  76%        |
# | 57           | 72-75°C   |  957          |  75%        |
# | 50           | 67-70°C   |  919          |  72%        |
# | no_turbo=1   | 69-72°C   |  911          |  71%        |
#
# 57% is the sweet spot: stays at 72-75°C under sustained full load with
# 75% of baseline single/multi-threaded performance. This is the cost of
# MX4 where liquid metal should be.
#
# NOTE(Krey): intel_pstate ignores per-core scaling_max_freq — freq control
# is package-wide only. Per-core frequency selection is NOT possible with
# this driver. The only options are max_perf_pct (global cap) or no_turbo
# (disable turbo entirely). To get per-core control, one would need to
# disable intel_pstate (intel_pstate=disable) and use acpi-cpufreq, which
# does respect per-core scaling_max_freq but loses HWP and hardware P-state
# management.
#
# The target temperature is configurable via hardware.thermal.targetTemp.
# The max_perf_pct value is derived empirically from the test data above.
# A linear interpolation from the data points yields approximately:
#   max_perf_pct = targetTemp * 0.25 + 37.5
# This is a rough approximation; the actual relationship is non-linear due
# to the cubic relationship between frequency, voltage, and power draw
# (P = C × V² × f, where V scales with f on intel_pstate).

let
	inherit (lib) mkOption;
	in {
	options.hardware.thermal.targetTemp = mkOption {
		type = lib.types.int;
		default = 80;
		description = ''
			Maximum CPU package temperature in degrees Celsius under sustained load.
			The intel_pstate max_perf_pct is derived empirically from stress testing
			on this hardware with MX4 thermal paste (should be liquid metal).

			Tested values:
			  50°C target -> max_perf_pct=50 -> 67-70°C actual, 72% perf
			  80°C target -> max_perf_pct=57 -> 72-75°C actual, 75% perf
			  No limit    -> max_perf_pct=100 -> 96-100°C actual, 100% perf

			Higher values = more performance but higher temperatures.
			The default of 80 provides a safe margin below Tj_max (100°C).
		'';
	};

	config = let
		targetTemp = config.hardware.thermal.targetTemp;

		# Empirical mapping from target temp to max_perf_pct
		# Derived from stress test data points on i7-12700H with MX4
		# Linear fit through tested values: 50°C→50%, 80°C→57%
		# Slope: (57-50)/(80-50) = 7/30 ≈ 0.233 per °C
		# At 100°C target this would give ~62%, which is optimistic —
		# the relationship flattens at higher temps due to voltage scaling
		maxPerfPct = toString (lib.min 100 (lib.max 10 (builtins.floor (targetTemp * 0.25 + 37.5))));
	in {
		# Cap intel_pstate maximum P-state to enforce thermal ceiling
		# This is the primary thermal throttle — limits frequency × voltage
		# Applied via kernel parameter so it takes effect before any userspace
		boot.kernelParams = [
			"intel_pstate.max_perf_pct=${maxPerfPct}"
		];

		# Intel Thermal Daemon as safety net for transient spikes
		# thermald monitors DTS (Digital Thermal Sensor) per-core and applies
		# additional throttling via intel_powerclamp (idle injection) when
		# max_perf_pct alone isn't sufficient (e.g., ambient temperature spikes)
		#
		# NOTE(Krey): thermald with generic config has limited effectiveness on
		# this hardware — no DPTF tables available. The --adaptive mode polls
		# sensors and clamps proportionally. It serves as a secondary safety net,
		# not the primary throttle.
		services.thermald.enable = true;
	};
}
