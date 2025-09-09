#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

# shellcheck disable=SC2154 # Do not trigger SC2154 for variables provided to the environment by Nix
{
	: "$systemDevice" # Absolute path to target device by id
	: "$systemSwapDevice" # Absolute path to the swap device by partlabel
	: "$secretPasswordPath" # Path to the file storing decrypted secret with disk password
	: "$secretSSHHostKeyPath" # Path to the private SSH key of the system
	: "$nixiumDoNotReboot" # Internal variable to prevent reboot after installation for special use-cases
	: "$derivation" # Derivation to be deployed
}

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
# status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
# warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

die 23 "Not Implemented!"

# https://github.com/FuriLabs/lvglcharger Used to display charging when the phone is off?
# https://github.com/FuriLabs/bootman wtf?
# Relevant: https://github.com/FuriLabs/flash-bootimage/blob/forky/src/flash-bootimage
# Relevant: https://github.com/FuriLabs/furios-quirks

#? DESIGN(Krey): Get the Modem Firmware
#? DESING(Krey): Get the Vendor FIrmware
#? DESIGN(Krey): Generate the rootfs
#? DESIGN(Krey): Handle recovery

#? DESIGN(Krey): Check if the device is connected and in fastboot mode

#? DESIGN(Krey): Flash modem firmware in `md1img_a` partition

#? DESIGN(Krey): Flash vendor firmware in `dynpart-vendor_a` partition
#? DESIGN(Krey): Flash vendor firmware in `dynpart-vendor_b` partition

#? DESIGN(Krey): Install recovery on the device somehow... it's initramfs hook

#? DESIGN(Krey): Flash nvdata harvested from the device and supplied by AGE
#? DESIGN(Krey): Flash nvrum harvested from the device and supplied by AGE
#? DESIGN(Krey): Flash nvcfg harvested from the device and supplied by AGE

#? DESIGN(Krey): Flash rootfs to userdata partition
