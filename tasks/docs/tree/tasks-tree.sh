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

# shellcheck disable=SC2034 # It's not expected to be always used
hostname="$(hostname --short)" # Capture the hostname of the current system

### [END] Export this outside [END] ###

# Function to print the directory tree with .about descriptions
print_tree() {
		dir="$1"
		level="$2"
		indent=""

		# Generate indentation based on the level
		for _ in $(seq 1 "$level"); do
				indent="&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$indent"
		done

		# Check if this directory contains a .about file
		about_file="$dir/.about"
		about_message=""

		if [ -f "$about_file" ]; then
				about_message=" -- $(cat "$about_file")"
				# Print the directory with its .about content if exists
				echo "${indent}├── **$(basename "$dir")**$about_message<br/>"
		else
				# Debugging: List all directories being processed
				echo "DEBUG: Skipping $dir (no .about file)"
		fi
}

# Check if the user provided the FLAKE_ROOT as an argument or environment variable
if [ -z "$FLAKE_ROOT" ]; then
		echo "Please set the FLAKE_ROOT environment variable to the root of the git repository."
		exit 1
fi

# Finding all .about files and collecting directories
echo "Finding all .about files..."
about_dirs=$(find "$FLAKE_ROOT" -type f -name ".about" -exec dirname {} \; | sort)

# Debug output: list of directories found
echo "Found .about files in the following directories:"
echo "$about_dirs"

# Sort directories by their relative depth (count of slashes)
sorted_dirs=$(echo "$about_dirs" | sort -t/ -k1,1 -k2,2 -k3,3)

# Now we will process each directory and print the tree
echo "FLAKE_ROOT is set to: $FLAKE_ROOT"
echo "Processing directories:"
for dir in $sorted_dirs; do
		# Get the relative path from FLAKE_ROOT
		relative_dir="${dir#"$FLAKE_ROOT/"}"

		# Calculate the level by counting slashes (depth of the directory)
		level=$(echo "$relative_dir" | tr -cd '/' | wc -c)

		# Output the directory tree
		print_tree "$dir" "$level"
done
