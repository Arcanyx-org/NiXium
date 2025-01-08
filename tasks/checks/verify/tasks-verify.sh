#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

# FIXME-QA(Krey): This should be a runtimeInput
sucess() { # Successfull Termination Helper
	case "$1" in
		"") exit 0 ;;
		*) printf "SUCCESS: %s\n" "$1"
	esac
}

# FIXME(Krey): This should be managed for all used scripts e.g. runtimeEnv
# Refer to https://github.com/srid/flake-root/discussions/5 for details tldr flake-root doesn't currently allow parsing the specific commit
#[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits" | jq -r '.[0].sha')"
[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits?sha=central" | jq -r '.[0].sha')"

# shellcheck disable=SC2034 # hostname is not required to be always used
hostname="$(hostname --short)"

### [END] Export this outside [END] ###

# Check current system if no argument is provided
[ "$#" != 0 ] || {
	machine="$1"
	derivation="$(grep "$machine" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

	# FIXME(Krey): It's possible that current system has deployed a configuration that is different from the one in the repo -> Get this derivation somewhere on the filesystem and try to read that first
	status "Checking current system's configured derivation: $derivation"

	nixos-rebuild dry-build \
		--flake "git+file://$FLAKE_ROOT#$derivation" \
		--option eval-cache false \
		--show-trace || die 1 "Verification of the current system failed"

	sucess
}

# FIXME-QA(Krey): Hacky af
nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')" # Get a space-separated list of all systems in the nixos distribution of NiXium

# If special argument 'all' is used then verify all systems across all distributions and all releases
[ "$1" != "all" ] || {
	# FIXME(Krey): Once we have more distros this needs management
	distro="nixos"

	# NixOS Distribution
	for system in $nixosSystems; do
		status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"

		case "$status" in
			"OK")
				for release in $(find "$FLAKE_ROOT/src/nixos/machines/$system/releases/"* -maxdepth 0 -type f | sed -E "s#^$FLAKE_ROOT/src/nixos/machines/$system/releases/##g" | sed -E "s#.nix##g" | tr '\n' ' '); do
					echo "Checking system '$system' in distribution '$distro', release '$release'"

					nixos-rebuild \
						dry-build \
						--flake "git+file://$FLAKE_ROOT#nixos-$system-$release" \
						--option eval-cache false \
						--show-trace || die 1 "System '$system' in distribution '$distro' of release '$release' failed evaluation!"
				done
			;;
			"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
			*) echo "System '$system' reports undeclared status state: $status"
		esac
	done

	sucess
}

[ "$#" != 1 ] || {
	machine="$1"
	derivation="$(grep "$machine" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

	status "Checking configured release: $derivation"

	nixos-rebuild dry-build \
		--flake "git+file://$FLAKE_ROOT#$derivation" \
		--option eval-cache false \
		--show-trace || die 1 "Verification of the derivation '$derivation' failed"

	sucess
}

# If special argument `all` is used as second argument then process all releases and distros that match the first argument as machine name
[ "$2" != "all" ] ||  {
	machine="$1"

	STATUS "Checking all distributions that contain machine '$machine'"

	# NixOS Distribution
	status="$(cat "$FLAKE_ROOT/src/nixos/machines/$machine/status")"
	distro="nixos"

	case "$status" in
		"OK")
			for release in $(find "$FLAKE_ROOT/src/nixos/machines/$machine/releases/"* -maxdepth 0 -type d | sed -E "s#^$FLAKE_ROOT/src/nixos/machines/$machine/releases/##g" | sed -E "s#.nix##g" | tr '\n' ' '); do
				echo "Checking machine '$machine' in distribution '$distro', release '$release'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
					--option eval-cache false \
					--show-trace || die 1 "System '$system' in distribution '$distro' of release '$release' failed evaluation!"
			done
		;;
		"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
		*) echo "System '$system' reports undeclared status state: $status"
	esac

	sucess
}

# Process Arguments
distro="$1" # e.g. nixos
machine="$2" # e.g. tupac, tsvetan, sinnenfreude or special `all`
release="$3" # Optional argument uses stable as default, ability to set supported release e.g. unstable or master

case "$distro" in
	"nixos") # NixOS Management

		# Process all systems in NixOS distribution if `nixos all` is used
		[ "$2" != "all" ] || {
			for system in $nixosSystems; do
				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
				case "$status" in
					"OK")
						echo "Checking release '$release' of distribution '$distro' for system '$system'"

						nixos-rebuild \
							dry-build \
							--flake "git+file://$FLAKE_ROOT#nixos-$system-$release" \
							--option eval-cache false \
							--show-trace || echo "WARNING: System '$system' in distribution '$distro' failed evaluation!"
					;;
					"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
					*) echo "System '$system' reports undeclared status state: $status"
				esac
			done
		}

		# Check if the system is defined
		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "This system '$machine' is not implemented in NiXium's management of distribution '$distro'"

		[ -n "$3" ] || {
			echo "Processing all available releases for machine '$machine' in distribution '$distro'"

			for release in $(find "$FLAKE_ROOT/src/nixos/machines/$machine/releases/"* -maxdepth 0 -type f | sed -E "s#^$FLAKE_ROOT/src/nixos/machines/$machine/releases/##g" | sed -E "s#.nix##g" | tr '\n' ' '); do
				echo "Checking system '$machine' in distribution '$distro', release '$release'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
					--option eval-cache false \
					--show-trace || die 1 "System '$machine' in distribution '$distro' of release '$release' failed evaluation!"
			done

			exit 0 # Success
		}

		# Process the system
		echo "Checking system '$machine' in distribution '$distro' and release '$release'"

		nixos-rebuild \
			dry-build \
			--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
			--option eval-cache false \
			--show-trace || die 1 "System '$machine' in distribution '$distro' and release '$release' failed evaluation"
	;;
	*) die 1 "Distribution '$distro' is not implemented!"
esac
