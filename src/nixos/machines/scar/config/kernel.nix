{ lib, pkgs, ... }:

# Kernel management of SCAR

{
	# boot.kernelPackages = pkgs.linuxPackages_xanmod;
	boot.kernelPackages = pkgs.linuxPackages;

	boot.kernelParams = [];

	# SECURITY(Krey): NiXium-important packages require this atm
	# * vscodium - Pending management on MORPH (remote codium server)
	security.unprivilegedUsernsClone = true;

	# Disable TPM — proprietary firmware we don't trust. The kernel probes it via the built-in CRB driver
	# and systemd waits ~19s for the device to become ready. Setting SYSTEMD_READY=0 tells udev to
	# mark it as "never ready" so systemd doesn't block on it during boot.
	services.udev.extraRules = ''
		# TPM — proprietary firmware, not trusted
		SUBSYSTEM=="tpm", ENV{SYSTEMD_READY}="0"
		SUBSYSTEM=="tpmrm", ENV{SYSTEMD_READY}="0"

		# Legacy serial ports — no physical RS-232 connectors on this laptop
		SUBSYSTEM=="tty", KERNEL=="ttyS[0-3]", ENV{SYSTEMD_READY}="0"
	'';
	boot.blacklistedKernelModules = [
		"lpc_ich" # Conflicts with ACPI (https://forums.gentoo.org/viewtopic-t-1068292-start-0.html)
		"tpm_tis_spi"
		"tpm_tis_i2c"
		"tpm_tis_i2c_cr50"
		"tpm_tis_i2c_atmel"
		"tpm_tis_i2c_infineon"
		"tpm_tis_i2c_nuvoton"
		"tpm_tis_st33zp24"
		"tpm_tis_st33zp24_i2c"
		"tpm_tis_st33zp24_spi"
	];

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		# FIXME(Krey): Fix for 25.11
			# (mkIf config.networking.wireguard.enable "wireguard")
	];
}
