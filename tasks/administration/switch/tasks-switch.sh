# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;} # Termination Helper

hostname="$(hostname --short)" # Capture the hostname of the current system

# FIXME-QA(Krey): Hacky af
derivation="$(grep "$hostname" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

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
			--verbose \
			--flake "git+file://$FLAKE_ROOT#$distro-$machine-$release" \
			--option eval-cache false || die 1 "Derivation '$distro-$machine-$release' failed to deploy on current system"
