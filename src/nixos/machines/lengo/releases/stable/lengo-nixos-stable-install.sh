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
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

# FIXME(Krey): This should be managed for all used scripts e.g. runtimeEnv
# Refer to https://github.com/srid/flake-root/discussions/5 for details tldr flake-root doesn't currently allow parsing the specific commit
#[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits" | jq -r '.[0].sha')"
[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits?sha=central" | jq -r '.[0].sha')"

### [END] Export this outside [END] ###

[ "$(id -u || true)" = 0 ] || die 126 "This script must be executed as the root user" # Ensure that we are root

# Check if the declared installation device is available on the target system
[ -b "$systemDevice" ] || die 1 "Expected device was not found, refusing to install for safety"

###! This script performs declarative installation of NiXium-Managed NixOS STABLE for the current system
###!
###! For that we utilize:
###! * Ragenix <https://github.com/yaxitech/ragenix> - The Rust implementation of agenix which is used to handle secrets in a declarative way
###! * Disko (specifically 'disko-install') <https://github.com/nix-community/disko> - NixOS utility used to declaratively format disks and perform system installation
###!
###! First we need to decrypt the needed secrets mainly we need:
###! * The disk encryption password - Used to encrypt the disks
###! * Private SSH host key - Required by NiXium to differenciate the system and ability to decrypt secrets
###!
###! ..in the ragenix-expected directory which is `/run/agenix/<SECRET>`.
###!
###! Then we pre-build the system configuration to avoid rebuilds and lesser the risk of failure later and initialize the disko-install payload after which the system will reboot into the new Operating System.
###!
###! Warning: For this payload to work we require that the disks that we are manipulating are not used to boot the current Operating System as otherwise disko-install will fail for safety. Use recovery disk or load a minimal nixos installer in the Random Access Memory ("RAM")

#! Ensure sane Ragenix Secret Directory ("RSD")
# By default the RSD is a symlink to /run/agenix.d/<num>
if [ -L "/run/agenix" ]; then
	status "Required Ragenix Secret Directory is present"

else # We assume that ragenix is not deployed on the target system
	status "Expected Ragenix Secret Directory is not present, setting up manually"

	[ -d "/run/agenix" ] || mkdir --verbose --parents  /run/agenix.d/1

	ln --verbose --symbolic /run/agenix.d/1 /run/agenix # Perform the symlink

	# Ensure that the RSD has the expected permissions
	chown --verbose "root:root" "/run/agenix.d/1" # Ensure expected ownership
	chmod --verbose 700 "/run/agenix.d/1" # Ensure expected permission

	status "Ragenix Secret Directory has been set up"
fi

#! Set up the identity file
status "Verifying the Identity File"

[ -n "$ragenixIdentity" ] || ragenixIdentity="$HOME/.ssh/id_ed25519" # Try to use the default path

# If the identity file is provided then use it to decrypt the secrets otherwise use hard-coded secrets
if [ -f "$ragenixIdentity" ]; then
	status "The identity file is provided trying to decrypt the secrets"

	[ -s "/run/agenix/$machineName-disks-password" ] || age --identity "$ragenixIdentity" --decrypt --output "/run/agenix/$machineName-disks-password" "$secretPasswordPath"

	[ -s "/run/agenix/$machineName-ssh-ed25519-private" ] || age --identity "$ragenixIdentity" --decrypt --output "/run/agenix/$machineName-ssh-ed25519-private" "$secretSSHHostKeyPath"

	status "Decrypting of required secrets was successful"
else
	status "Required Identity File was not found, managing by using hard-coded secrets"

	warn "BEWARE THAT USING HARD-CODED SECRETS IS A SECURITY HOLE!"

	[ -s "/run/agenix/$machineName-disks-password" ] || echo "000000" > "/run/agenix/$machineName-disks-password"

	[ -s "/run/agenix/$machineName-ssh-ed25519-private" ] || ssh-keygen -f "/run/agenix/$machineName-ssh-ed25519-private" -N ""
fi

#! Format the disks
status "Formatting disks"
disko \
	--mode "disko" \
	--root-mountpoint "/mnt" \
	--debug \
	--flake "$FLAKE_ROOT#$derivation"

#! # Activate SWAP
#! To prevent issues with lack of memory on systems with less than 16 GB of RAM
# FIXME-QA(Krey): Do not run swapon if the swap is already activated
# FIXME-QA(Kret): Use the device declaratively for activating swap
# status "Activating swap"
# swapon "$(realpath "$systemSwapDevice" || true)"
# swapon "/dev/mapper/swap" || true

# These have to be implemented for the installer to not fail with out of memory err
# FIXME-QA(Krey): Do not run these if the size is already adjusted
# mount -o remount,size=20G,noatime /nix/.rw-store
# mount -o remount,size=5G,noatime /mnt

#! Pre-build the system configuration
status "Pre-building the system configuration"
nixos-rebuild build --flake "$FLAKE_ROOT#$derivation" # pre-build the configuration

#! Perform the installation
status "Performing the system installation"
nixos-install \
	--verbose \
	--root "/mnt" \
	--flake "$FLAKE_ROOT#$derivation"

#! # Insert the secret
#! This is used to manage the chicken-and-an-egg problem with assigning system cryptographical keys
status "Injecting cryptographical identification"
age \
	--identity "$ragenixIdentity" \
	--decrypt \
	--output "/mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key" \
	"/run/agenix/$machineName-ssh-ed25519-private"

#! Flash the Embedded Controller
# FIXME(Krey)

#! Flash Coreboot
# FIXME(Krey): Management at https://github.com/NiXium-org/coreboot/issues/2

#! Reboot in the new Operating System
[ "$nixiumDoNotReboot" = 0  ] || {
	status "Installation was successful, performing reboot"
	reboot
}
