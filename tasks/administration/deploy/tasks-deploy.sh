# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

hostname="$(hostname --short)" # Capture the hostname of the current system

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;} # Termination Helper

# Check current system if no argument is provided
[ "$#" != 0 ] || {
	# FIXME(Krey): This needs logic to determine the distribution and release
	echo "Deploying Stable Release of NixOS distribution on current system '$hostname'"

	nixos-rebuild switch \
		--flake "git+file://$FLAKE_ROOT#nixos-$hostname-stable" \
		--option eval-cache false \
		--verbose \
		--show-trace || die 1 "Deployment of the stable release of NixOS distribution on the current system failed"

	exit 0 # Success
}

# If only 1 argument is provided then deploy the configured system on said unique machine name
[ "$#" != 1 ] || {
	machine="$1"
	derivation="$(grep "$machine" "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

	echo "Deploying configured derivation for '$machine', which is: $derivation"

	nixos-rebuild switch \
		--flake "git+file://$FLAKE_ROOT#$derivation" \
		--option eval-cache false \
		--verbose \
		--target-host "root@$machine.systems.nx" || die 1 "Deployment of the configured derivation '$derivation' on machine '$machine' failed"

		exit 0 # Success
}

# If special argument 'all' is used then deploy the specified distribution and release on all systems
[ "$1" != "all" ] || {
	for system in $(grep -vP "^#" "$FLAKE_ROOT/config/machine-derivations.conf" | grep -vP "^/n$" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\1#g' | tr '\n' ' '); do
		derivation="$(grep mracek "$FLAKE_ROOT/config/machine-derivations.conf" | sed -E 's#^(\w+)(\s)([a-z\-]+)#\3#g')"

		nixos-rebuild switch \
		--flake "git+file://$FLAKE_ROOT#$derivation" \
		--option eval-cache false \
		--target-host "root@$system.systems.nx" || echo "WARNING: derivation '$derivation' failed deployment for system '$system'"
	done
}

# Process Arguments
distro="$1" # e.g. nixos
machine="$2" # e.g. tupac, tsvetan, sinnenfreude
release="${3-"stable"}" # Optional argument uses stable as default, ability to set supported release e.g. unstable or master

nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')" # Get a space-separated list of all systems in the nixos distribution of NiXium

case "$distro" in
	"nixos") # NixOS Management

		# Process all systems in NixOS distribution if `nixos all` is used
		[ "$machine" != "all" ] || {
			for system in $nixosSystems; do
				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
				case "$status" in
					"OK")
						echo "Deploying NixOS distribution release '$release' on system '$system'"

						nixos-rebuild switch \
							--flake "git+file://$FLAKE_ROOT#nixos-$system-$release}" \
							--option eval-cache false \
							--target-host "root@$system.systems.nx" || die 1 "System '$system' in distribution '$distro' and release '$release' failed deployment!"
					;;
					"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
					*) echo "System '$system' reports undeclared status state: $status"
				esac
			done
		}

		# Check if the system is defined
		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "This system '$machine' is not implemented in NiXium's management of distribution '$distro'"

		# Process the system
		echo "Deploying system '$machine' in distribution '$distro' and release '$release'"

		nixos-rebuild \
			switch \
			--flake "git+file://$FLAKE_ROOT#nixos-$machine-$release" \
			--option eval-cache false \
			--target-host "root@$machine.systems.nx"  || echo "WARNING: System '$machine' in distribution '$distro' failed evaluation!"
	;;
	*) die 1 "Distribution '$distro' is not implemented for deployments!"
esac
