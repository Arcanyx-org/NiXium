# shellcheck shell=sh # POSIX
set +u # Do not fail on nounset as we use command-line arguments for logic

# Refer to https://github.com/nix-community/disko/issues/657#issuecomment-2146978563 for implementation notes

# FIXME(Krey): Implement better management for this so that ideally `die` is always present by default
command -v die 1>/dev/null || die() { printf "FATAL: %s\n" "$2"; exit 1 ;} # Termination Helper

distro="$1"
system="$2"
release="$3"

# Input check
[ -n "$distro" ] || die 1 "First Argument (distribution) is required for the install task"
[ -n "$system" ] || die 1 "Second Argument (system) is required for the install task"
[ -n "$release" ] || die 1 "Third Argument (release) is required for the install task"

echo "WARNING: This action will wipe all data on the target device and performs full declarative re-installation!"

# Perform the task
# FIXME(Krey): Figure out how to parse FLAKE_ROOT to the payload
sudo nix --extra-experimental-features 'nix-command flakes' run --impure "git+file://$FLAKE_ROOT#$distro-$system-$release-install"
