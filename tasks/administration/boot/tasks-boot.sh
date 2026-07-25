# DNC(Krey): These scripts do not conform to the coding quality of Arcanyx organization and are used for research to figure out the spec for proper implementation

# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;}

hostname="$(hostname --short)"

# Resolve the machine alias to its target nixosConfiguration via _derivationName attribute
derivation=$(nix eval ".#nixosConfigurations.nixos-$hostname._derivationName" --raw 2>/dev/null || echo "$hostname")

[ "$#" != 0 ] || {
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
			--flake "git+file://$FLAKE_ROOT#$hostname" \
			--option eval-cache false \
			--show-trace || die 1 "Boot of system '$hostname' ($derivation) failed"

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
		--show-trace || die 1 "Boot of system '$machine' via #$distro-$machine-$release failed"
