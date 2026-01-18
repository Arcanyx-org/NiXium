#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

# shellcheck disable=SC2154 # Do not trigger SC2154 for variables provided to the environment by Nix
# {...}

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

### [END] Export this outside [END] ###

# FIXME(Krey): Implement a way to check if the system is available on local network to prefer that over Tor

# shellcheck disable=SC2029 # We expect this to expand on client side
ssh root@sinnenfreude.systems.nx "$@"
