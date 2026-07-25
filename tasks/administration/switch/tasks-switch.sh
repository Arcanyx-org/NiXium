# DNC(Krey): These scripts do not conform to the coding quality of Arcanyx organization and are used for research to figure out the spec for proper implementation

# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;}

hostname="$(hostname --short)"

# Resolve the machine alias to its target nixosConfiguration via _derivationName attribute
derivation=$(nix eval ".#nixosConfigurations.nixos-$hostname._derivationName" --raw 2>/dev/null || echo "$hostname")

case "$@" in
	"")
		echo "Switching current system: $hostname ($derivation)"

		ssh root@localhost \
			nixos-rebuild switch \
				--flake "git+file://$FLAKE_ROOT#$hostname" \
				--option eval-cache false || die 1 "Switch of system '$hostname' ($derivation) failed"
	;;
	"nixos *")
		machine="$2"
		release="$3"

		[ -n "$machine" ] || die 1 "Second Argument (machine) is required for the switch task"
		[ -n "$release" ] || die 1 "Third Argument (release) is required for the switch task"

		echo "Switching system '$machine' (via #$machine) to release '$release'"

		ssh root@localhost \
			nixos-rebuild switch \
				--verbose \
				--flake "git+file://$FLAKE_ROOT#$machine" \
				--option eval-cache false || die 1 "Switch of system '$machine' (via #$machine) failed"
	;;

esac

[ "$#" != 0 ] || {
	echo "Switching current system: $hostname ($derivation)"

	ssh root@localhost \
		nixos-rebuild switch \
			--verbose \
			--flake "git+file://$FLAKE_ROOT#$hostname" \
			--option eval-cache false || die 1 "Switch of system '$hostname' ($derivation) failed"

	exit 0 # Success
}

distro="$1"
machine="$2"
release="$3"

[ -n "$distro" ] || die 1 "First Argument (distribution) is required for the switch task"
[ -n "$machine" ] || die 1 "Second Argument (machine) is required for the switch task"
[ -n "$release" ] || die 1 "Third Argument (release) is required for the switch task"

ssh root@localhost \
		nixos-rebuild switch \
			--verbose \
			--flake "git+file://$FLAKE_ROOT#$distro-$machine-$release" \
			--option eval-cache false || die 1 "Switch of system '$machine' via #$distro-$machine-$release failed"
