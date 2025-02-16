#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

# Termination Helper
command -v success 1>/dev/null || success() {
	case "$1" in
		"") : ;;
		*) printf "SUCCESS: %s\n" "$1"
	esac

	exit 0
}

# FIXME(Krey): This should be managed for all used scripts e.g. runtimeEnv
# Refer to https://github.com/srid/flake-root/discussions/5 for details tldr flake-root doesn't currently allow parsing the specific commit
#[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits" | jq -r '.[0].sha')"
[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits?sha=central" | jq -r '.[0].sha')"

# shellcheck disable=SC2034 # It's not expected to be always used
hostname="$(hostname --short)" # Capture the hostname of the current system

### [END] Export this outside [END] ###

# Refer to https://github.com/nix-community/disko/issues/657#issuecomment-2146978563 for implementation notes

distro="$1"
system="$2"
release="$3"

# Input check
[ -n "$distro" ] || die 1 "First Argument (distribution) is required for the install task"
[ -n "$system" ] || die 1 "Second Argument (system) is required for the install task"
[ -n "$release" ] || die 1 "Third Argument (release) is required for the install task"

echo "WARNING: This action will wipe all data on the target device and performs full declarative re-installation!"

# Perform the task
# FIXME(Krey): Figure out how to parse FLAKE_ROOT to the payload
sudo nix --extra-experimental-features 'nix-command flakes' run --impure "git+file://$FLAKE_ROOT#$distro-$system-$release-install"
