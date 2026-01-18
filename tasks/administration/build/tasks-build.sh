# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

hostname="$(hostname --short)" # Capture the hostname of the current system

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;} # Termination Helper

command -v success 1>/dev/null || success() { printf "SUCCESS: %s\n" "$1"; exit 0 ;} # Termination Helper

# Check current system if no argument is provided
[ "$#" != 0 ] || {
	# FIXME(Krey): This needs logic to determine the distribution and release
	echo "Building current system: $hostname"

	nixos-rebuild build \
		--flake "git+file://$FLAKE_ROOT#nixos-$hostname-stable" \
		--option eval-cache false \
		--show-trace || die 1 "Build of the current system failed"

	exit 0 # Success
}

# Assume that we are always checking against nixos distribution with stable release
[ "$#" != 1 ] || {
	echo "Building stable release of system '$1' in NixOS distribution"

	nixos-rebuild build \
		--flake "git+file://$FLAKE_ROOT#nixos-$1-stable" \
		--option eval-cache false \
		--show-trace || die 1 "Build of the '$1' system on NixOS distribution using stable release failed"

	success "Build of derivation '$1' was successful"
}

nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')" # Get a space-separated list of all systems in the nixos distribution of NiXium

# If special argument 'all' is used then build all systems across all distributions and all releases
[ "$1" != "all" ] || {
	# NixOS Distribution
	for system in $nixosSystems; do
		status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"

		case "$status" in
			"OK")
				echo "Checking system '$system' in distribution '$distro'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#nixos-$system-${release:-"stable"}" \
					--option eval-cache false \
					--show-trace || echo "WARNING: System '$system' in distribution '$distro' failed evaluation!"
			;;
			"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
			*) echo "System '$system' reports undeclared status state: $status"
		esac
	done
}

# Process Arguments
distro="$1" # e.g. nixos
machine="$2" # e.g. tupac, tsvetan, sinnenfreude
release="$3" # Optional argument uses stable as default, ability to set supported release e.g. unstable or master

case "$distro" in
	"nixos") # NixOS Management

		# Process all systems in NixOS distribution if `nixos all` is used
		[ "$machine" != "all" ] || {
			for system in $nixosSystems; do
				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
				case "$status" in
					"OK")
						echo "Building system '$system' in distribution '$distro'"

						nixos-rebuild \
							build \
							--flake "git+file://$FLAKE_ROOT#nixos-$system-${release:-"stable"}" \
							--option eval-cache false \
							--show-trace || echo "WARNING: System '$system' in distribution '$distro' failed build!"
					;;
					"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
					*) echo "System '$system' reports undeclared status state: $status"
				esac
			done
		}

		# Check if the system is defined
		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "This system '$machine' is not implemented in NiXium's management of distribution '$distro'"

		# Process the system
		echo "Building system '$machine' in distribution '$distro'"

		nixos-rebuild \
			build \
			--flake "git+file://$FLAKE_ROOT#nixos-$machine-${release:-"stable"}" \
			--option eval-cache false \
			--show-trace || echo "WARNING: System '$machine' in distribution '$distro' failed evaluation!"
	;;
	*) die 1 "Distribution '$distro' is not implemented!"
esac
