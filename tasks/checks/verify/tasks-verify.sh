#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

# DNC(Krey): These scripts do not conform to the coding quality of Arcanyx organization and are used for research to figure out the spec for proper implementation

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

# FIXME-QA(Krey): This should be a runtimeInput
# shellcheck disable=SC2120 # Argument is optional
success() { # Successfull Termination Helper
	printf "SUCCESS: %s\n" "${1:-"Task Finished Successfully"}"
	exit 0
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
	derivation=$(nix eval ".#nixosConfigurations.nixos-$hostname._derivationName" --raw 2>/dev/null || echo "$hostname")

	status "Verifying current system: $hostname ($derivation)"

	nixos-rebuild dry-build \
		--flake "git+file://$FLAKE_ROOT#$hostname" \
		--option eval-cache false \
		--show-trace || die 1 "Verification of system '$hostname' ($derivation) failed"

	success
}

nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')"

[ "$1" != "all" ] || {
	distro="nixos"

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
			"WIP") echo "System '$system' is Work-in-Progress, skipping.." ;;
			*) echo "System '$system' has undeclared status: $status"
		esac
	done

	success
}

[ "$#" != 1 ] || {
	machine="$1"

	derivation=$(nix eval ".#nixosConfigurations.nixos-$machine._derivationName" --raw 2>/dev/null || echo "$machine")

	status "Verifying machine '$machine' ($derivation)"

	nixos-rebuild dry-build \
		--flake "git+file://$FLAKE_ROOT#$machine" \
		--option eval-cache false \
		--show-trace || die 1 "Verification of machine '$machine' ($derivation) failed"

	success
}

[ "$2" != "all" ] || {
	machine="$1"

	status "Verifying all releases for machine '$machine'"

	distro="nixos"
	status="$(cat "$FLAKE_ROOT/src/nixos/machines/$machine/status")"

	case "$status" in
		"OK")
			for release in $(find "$FLAKE_ROOT/src/nixos/machines/$machine/releases/"* -maxdepth 0 -type d | sed -E "s#^$FLAKE_ROOT/src/nixos/machines/$machine/releases/##g" | sed -E "s#.nix##g" | tr '\n' ' '); do
				echo "Checking machine '$machine' in distribution '$distro', release '$release'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
					--option eval-cache false \
					--show-trace || die 1 "System '$machine' in distribution '$distro' of release '$release' failed evaluation!"
			done
		;;
		"WIP") echo "System '$machine' is Work-in-Progress, skipping.." ;;
		*) echo "System '$machine' has undeclared status: $status"
	esac

	success
}

distro="$1"
machine="$2"
release="$3"

case "$distro" in
	"nixos")
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
					"WIP") echo "System '$system' is Work-in-Progress, skipping.." ;;
					*) echo "System '$system' has undeclared status: $status"
				esac
			done
		}

		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "System '$machine' is not defined in NiXium"

		[ -n "$3" ] || {
			echo "Processing all available releases for machine '$machine'"

			for release in $(find "$FLAKE_ROOT/src/nixos/machines/$machine/releases/"* -maxdepth 0 -type f | sed -E "s#^$FLAKE_ROOT/src/nixos/machines/$machine/releases/##g" | sed -E "s#.nix##g" | tr '\n' ' '); do
				echo "Checking system '$machine' in distribution '$distro', release '$release'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
					--option eval-cache false \
					--show-trace || die 1 "System '$machine' in distribution '$distro' of release '$release' failed evaluation!"
			done

			exit 0
		}

		echo "Checking system '$machine' in distribution '$distro' and release '$release'"

		nixos-rebuild \
			dry-build \
			--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
			--option eval-cache false \
			--show-trace || die 1 "System '$machine' in distribution '$distro' and release '$release' failed evaluation"
	;;
	*) die 1 "Distribution '$distro' is not implemented!"
esac
