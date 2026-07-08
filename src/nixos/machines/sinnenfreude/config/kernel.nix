{ pkgs, config, lib, ... }:

# Kernel Management of SINNENFREUDE

let
	inherit (lib) mkIf;
in {
	# boot.kernelPackages = pkgs.linuxPackages_hardened; # Use hardened kernel
	boot.kernelPackages = pkgs.linuxPackages;

	# SECURITY(Krey): NiXium-important packages require this atm
	# * vscodium - Pending management on MORPH
	security.unprivilegedUsernsClone = true;

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		# FIXME(Krey): Fais on 25.11
			# (mkIf config.networking.wireguard.enable "wireguard")
	];

	# Blacklist drivers that cause dmesg noise or aren't needed
	boot.blacklistedKernelModules = [
		"nouveau"   # NVIDIA GTX 760M: Keeps Kepler at boot clocks, no reclocking;
		            # MKX 3.0b module will be removed; Intel iGPU handles display
		"gpio_ich"  # ACPI SystemIO conflicts on Haswell; gpio_ich can't claim resources
	];

	# Kernel parameters for hardware fixes and security
	boot.kernelParams = [
		"modprobe.blacklist=nouveau"  # Block nouveau before module init (blacklistedKernelModules only prevents auto-load)
		"modprobe.blacklist=gpio_ich" # Block gpio_ich early (ACPI SystemIO conflicts on Haswell)
		"video.allow_duplicates=1"  # ACPI _BCL backlight method tolerates missing symbols
		"trace_options=noautouser"  # Restrict tracefs to root-only (security: tracing info leak)
	];

	# Kernel patches
	boot.kernelPatches = [
		{
			# Silences "CONFIG_IMA_DISABLE_HTABLE is disabled" from device-mapper
			name = "ima-enable-htable";
			patch = null;
			extraConfig = "IMA_DISABLE_HTABLE y";
		}
	];
}
