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

# FIXME-QA(Krey): Hacky af
derivation="$(grep "$hostname" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

# FIXME-SECURITY(Krey): Temporary workaround before we figure out how to manage this
# shellcheck disable=SC2029 # We want the FLAKE_ROOT variable to expand on the client side
ssh root@localhost git config --system safe.directory "$FLAKE_ROOT" # Add the current repository into a safe directory to bypass failure of repository not owned by current user

# If no argument is used then switch the specified distribution on the current system
[ "$#" != 0 ] || {
	echo "Switching derivation '$derivation' on current system"

	ssh root@localhost \
		nixos-rebuild switch \
			--flake "git+file://$FLAKE_ROOT#$derivation" \
			--option eval-cache false || die 1 "Derivation '$derivation' failed to deploy on current system"

	exit 0 # Success
}

# Input check
[ -n "$distro" ] || die 1 "First Argument (distribution) is required for the switch task"
[ -n "$machine" ] || die 1 "Second Argument (machine) is required for the switch task"
[ -n "$release" ] || die 1 "Third Argument (release) is required for the switch task"

ssh root@localhost \
		nixos-rebuild switch \
			--flake "git+file://$FLAKE_ROOT#$distro-$machine-$release" \
			--option eval-cache false || die 1 "Derivation '$distro-$machine-$release' failed to deploy on current system"
