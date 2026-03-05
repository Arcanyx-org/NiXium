# shellcheck shell=sh # POSIX

# DNM(Krey): Agent-generated code, pending review
exit 66

# This script runs shellcheck on all .sh files
# Excludes deploy-experiment.sh files (experimental/incomplete)

if [ -z "$FLAKE_ROOT" ]; then
	echo "Please set the FLAKE_ROOT environment variable"
	exit 1
fi

# Print .shellcheckrc if it exists
if [ -f "$FLAKE_ROOT/.shellcheckrc" ]; then
	echo "=== Using .shellcheckrc configuration ==="
	cat "$FLAKE_ROOT/.shellcheckrc"
	echo ""
fi

# Find and check all shell scripts, excluding experimental files
echo "=== Running shellcheck on all .sh files ==="
find "$FLAKE_ROOT" -name "*.sh" -type f ! -name "deploy-experiment.sh" -exec shellcheck {} +
