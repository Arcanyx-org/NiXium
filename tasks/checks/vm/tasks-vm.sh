#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

# Termination Helper
command -v success 1>/dev/null || success() {
	case "$1" in
		"") : ;;
		*) printf "SUCCESS: %s\n" "$1"
	esac

	exit 0
}

# FIXME(Krey): This should be managed for all used scripts e.g. runtimeEnv
# Refer to https://github.com/srid/flake-root/discussions/5 for details tldr flake-root doesn't currently allow parsing the specific commit
#[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits" | jq -r '.[0].sha')"
[ -n "$FLAKE_ROOT" ] || FLAKE_ROOT="github:NiXium-org/NiXium/$(curl -s -X GET "https://api.github.com/repos/NiXium-org/NiXium/commits?sha=central" | jq -r '.[0].sha')"

hostname="$(hostname --short)" # Capture the hostname of the current system

### [END] Export this outside [END] ###

case "$#" in
	"0") # No Arguments
		# FIXME(Krey): This needs logic to determine the distribution and release
		status "Opening a Virtual Machine for current system: $hostname"

		nix run -L "$FLAKE_ROOT#nixosConfigurations.nixos-$hostname-stable.config.system.build.vmWithDisko" --verbose --show-trace

		success ""
	;;
	"1") # One Argument
		status "Opening a Virtual machine for stable release of system '$1' in NixOS distribution"

		nix run -L "$FLAKE_ROOT#nixosConfigurations.nixos-$1-stable.config.system.build.vmWithDisko" --verbose --show-trace

		success
	;;
	*) die 125 "These arguments are not implemented: $*"
esac




# TBD(Krey): Decide how to handle these

# nixosSystems="$(find "$FLAKE_ROOT/src/nixos/machines/"* -maxdepth 0 -type d | sed "s#^$FLAKE_ROOT/src/nixos/machines/##g" | tr '\n' ' ')" # Get a space-separated list of all systems in the nixos distribution of NiXium

# # Process Arguments
# distro="$1" # e.g. nixos
# machine="$2" # e.g. tupac, tsvetan, sinnenfreude
# release="$3" # Optional argument uses stable as default, ability to set supported release e.g. unstable or master

# case "$distro" in
# 	"nixos") # NixOS Management

# 		# Process all systems in NixOS distribution if `nixos all` is used
# 		[ "$machine" != "all" ] || {
# 			for system in $nixosSystems; do
# 				status="$(cat "$FLAKE_ROOT/src/nixos/machines/$system/status")"
# 				case "$status" in
# 					"OK")
# 						echo "Building system '$system' in distribution '$distro'"

# 						nixos-rebuild \
# 							build \
# 							--flake "git+file://$FLAKE_ROOT#nixos-$system-${release:-"stable"}" \
# 							--option eval-cache false \
# 							--show-trace || echo "WARNING: System '$system' in distribution '$distro' failed build!"
# 					;;
# 					"WIP") echo "Configuration for system '$system' in distribution '$distro' is marked a Work-in-Progress, skipping build.." ;;
# 					*) echo "System '$system' reports undeclared status state: $status"
# 				esac
# 			done
# 		}

# 		# Check if the system is defined
# 		[ -d "$FLAKE_ROOT/src/nixos/machines/$machine" ] || die 1 "This system '$machine' is not implemented in NiXium's management of distribution '$distro'"

# 		# Process the system
# 		echo "Building system '$machine' in distribution '$distro'"

# 		nixos-rebuild \
# 			build \
# 			--flake "git+file://$FLAKE_ROOT#nixos-$machine-${release:-"stable"}" \
# 			--option eval-cache false \
# 			--show-trace || echo "WARNING: System '$machine' in distribution '$distro' failed evaluation!"
# 	;;
# 	*) die 1 "Distribution '$distro' is not implemented!"
# esac
