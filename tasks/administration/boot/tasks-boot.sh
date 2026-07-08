# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;}

hostname="$(hostname --short)"

# FIXME-QA(Krey): Hacky af
derivation="$(grep "$hostname" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

[ "$#" != 0 ] || {
	[ -n "$derivation" ] || die 1 "Failed to look up derivation for host '$hostname' in $FLAKE_ROOT/config/machine-derivations.conf"

	status="$(cat "$FLAKE_ROOT/src/nixos/machines/$hostname/status")"

	case "$status" in
		"OK") ;;
		"WIP") echo "WARNING: System '$hostname' is marked Work-in-Progress. Boot may fail." ;;
		"KIA") die 1 "System '$hostname' is Killed In Action. Refusing to boot." ;;
		*) die 1 "System '$hostname' has undeclared status: $status" ;;
	esac

	echo "Booting current system: $hostname ($derivation)"

	ssh root@localhost \
		nixos-rebuild boot \
			--flake "git+file://$FLAKE_ROOT#$derivation" \
			--option eval-cache false \
			--show-trace || die 1 "Boot of the current system failed"

	exit 0
}

# Process Arguments
distro="$1"
machine="$2"
release="${3:-stable}"

# Validate machine exists
[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "Machine '$machine' is not defined in NiXium"

echo "Booting system '$machine' in distribution '$distro' using release '$release'"

ssh root@localhost \
	nixos-rebuild boot \
		--flake "git+file://$FLAKE_ROOT#$distro-$machine-$release" \
		--option eval-cache false \
		--show-trace || die 1 "Boot of system '$machine' failed"
