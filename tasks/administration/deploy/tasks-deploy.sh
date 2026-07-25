# DNC(Krey): These scripts do not conform to the coding quality of Arcanyx organization and are used for research to figure out the spec for proper implementation

# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

hostname="$(hostname --short)"

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;}

# Resolve the machine alias to its target nixosConfiguration via _derivationName attribute
derivation=$(nix eval ".#nixosConfigurations.nixos-$hostname._derivationName" --raw 2>/dev/null || echo "$hostname")

[ "$#" != 0 ] || {
	echo "Deploying current system: $hostname ($derivation)"

	nixos-rebuild switch \
		--flake "git+file://$FLAKE_ROOT#$hostname" \
		--option eval-cache false \
		--verbose \
		--show-trace || die 1 "Deployment of system '$hostname' ($derivation) failed"

	exit 0
}

[ "$#" != 1 ] || {
	machine="$1"

	echo "Deploying machine '$machine'"

	echo "Looking for localIP"
	localIP="$("ssh.$machine" "ip -4 addr show scope global | grep inet | awk '{print \$2}' | cut -d/ -f1 | head -1")"

	echo "Found Local IP: $localIP"

	if [ "$(ssh "root@$localIP" hostname || true)" = "$machine" ]; then
		echo "Deploying over local IP"
		nixos-rebuild switch \
			--flake "git+file://$FLAKE_ROOT#$machine" \
			--option eval-cache false \
			--verbose \
			--target-host "root@$localIP" || die 1 "Deployment of system '$machine' over local IP failed"
	else
		echo "Deploying over Tor"
		nixos-rebuild switch \
			--flake "git+file://$FLAKE_ROOT#$machine" \
			--option eval-cache false \
			--verbose \
			--target-host "root@$machine.systems.nx" || die 1 "Deployment of system '$machine' over Tor failed"
	fi

	exit 0
}

[ "$1" != "all" ] || {
	nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')"

	for system in $nixosSystems; do
		nixos-rebuild switch \
			--flake "git+file://$FLAKE_ROOT#$system" \
			--option eval-cache false \
			--target-host "root@$system.systems.nx" || echo "WARNING: Deployment of system '$system' failed"
	done
}

distro="$1"
machine="$2"
# shellcheck disable=SC2034 # release is reserved for future use when per-machine release override is needed
release="$3"

nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')"

case "$distro" in
	"nixos")
		[ "$machine" != "all" ] || {
			for system in $nixosSystems; do
				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
				case "$status" in
					"OK")
						echo "Deploying system '$system'"

						nixos-rebuild switch \
							--flake "git+file://$FLAKE_ROOT#$system" \
							--option eval-cache false \
							--target-host "root@$system.systems.nx" || die 1 "Deployment of system '$system' failed!"
					;;
					"WIP") echo "System '$system' is Work-in-Progress, skipping.." ;;
					"KIA") echo "System '$system' is Killed In Action, skipping.." ;;
					*) echo "System '$system' has undeclared status: $status"
				esac
			done
		}

		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "System '$machine' is not defined in NiXium"

		echo "Deploying system '$machine'"

		nixos-rebuild \
			switch \
			--flake "git+file://$FLAKE_ROOT#$machine" \
			--option eval-cache false \
			--target-host "root@$machine.systems.nx" || echo "WARNING: Deployment of system '$machine' failed!"
	;;
	*) die 1 "Distribution '$distro' is not implemented for deployments!"
esac
