# DNC(Krey): These scripts do not conform to the coding quality of Arcanyx organization and are used for research to figure out the spec for proper implementation

# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

hostname="$(hostname --short)"

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;}
command -v success 1>/dev/null || success() { printf "SUCCESS: %s\n" "$1"; exit 0 ;}

# Resolve the machine alias to its target nixosConfiguration via _derivationName attribute
derivation=$(nix eval ".#nixosConfigurations.nixos-$hostname._derivationName" --raw 2>/dev/null || echo "$hostname")

[ "$#" != 0 ] || {
	echo "Building current system: $hostname ($derivation)"

	nixos-rebuild build \
		--flake "git+file://$FLAKE_ROOT#$hostname" \
		--option eval-cache false \
		--show-trace || die 1 "Build of system '$hostname' ($derivation) failed"

	exit 0
}

[ "$#" != 1 ] || {
	echo "Building system '$1'"

	nixos-rebuild build \
		--flake "git+file://$FLAKE_ROOT#$1" \
		--option eval-cache false \
		--show-trace || die 1 "Build of system '$1' failed"

	success "Build of system '$1' was successful"
}

nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')"

[ "$1" != "all" ] || {
	for system in $nixosSystems; do
		status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"

		case "$status" in
			"OK")
				echo "Building system '$system'"

				nixos-rebuild \
					dry-build \
					--flake "git+file://$FLAKE_ROOT#$system" \
					--option eval-cache false \
					--show-trace || echo "WARNING: System '$system' failed evaluation!"
			;;
			"WIP") echo "System '$system' is Work-in-Progress, skipping.." ;;
			*) echo "System '$system' has undeclared status: $status"
		esac
	done
}

distro="$1"
machine="$2"
# shellcheck disable=SC2034 # release is reserved for future use when per-machine release override is needed
release="$3"

case "$distro" in
	"nixos")
		[ "$machine" != "all" ] || {
			for system in $nixosSystems; do
				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
				case "$status" in
					"OK")
						echo "Building system '$system'"

						nixos-rebuild \
							build \
							--flake "git+file://$FLAKE_ROOT#$system" \
							--option eval-cache false \
							--show-trace || echo "WARNING: System '$system' failed build!"
					;;
					"WIP") echo "System '$system' is Work-in-Progress, skipping.." ;;
					*) echo "System '$system' has undeclared status: $status"
				esac
			done
		}

		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "System '$machine' is not defined in NiXium"

		echo "Building system '$machine'"

		nixos-rebuild \
			build \
			--flake "git+file://$FLAKE_ROOT#$machine" \
			--option eval-cache false \
			--show-trace || echo "WARNING: System '$machine' failed evaluation!"
	;;
	*) die 1 "Distribution '$distro' is not implemented!"
esac
