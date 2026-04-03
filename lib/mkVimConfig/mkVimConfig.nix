# mkVimConfig — Vimscript config validator
#
# Takes pkgs and returns a function: { content, name ? "vim-config" } -> string
#
# Validates vimscript content using nvim in headless mode at build time.
# This is the vimscript analogue of writeShellApplication's shellcheck:
#   - Fails the build completely on syntax errors (hard failure)
#   - Warns on duplicate set commands, out-of-range numeric values, and risky options
#   - Returns the content string unchanged if all checks pass
#
# Using writeText to store content avoids shell-escaping special unicode
# characters that appear in listchars (·, ↵, ▷, etc.)

pkgs:

{ content, name ? "vim-config" }:

let
	inherit (builtins) readFile;
	inherit (pkgs.lib) concatStringsSep;

	# Write the content to the store so it can be referenced in the build
	# script without any shell-escaping concerns
	contentFile = pkgs.writeText "${name}-content" content;

	validated = pkgs.runCommandLocal "${name}-validated" {
		buildInputs = [ pkgs.neovim pkgs.gnused ];
		preferLocalBuild = true;
		allowSubstitutes = false;
	} (concatStringsSep "\n" [

		# Check 1: Syntax validation
		# nvim -V1:    verbosity level 1 — prints errors to stdout with line
		#              numbers and E-codes; without it nvim swallows all errors
		#              and the build log shows nothing useful to a human
		# -es:         silent batch/ex mode — non-interactive, no UI
		# -u NONE:     skip all user config files (vimrc, plugins)
		# -c "source": load the content file as vimscript
		# -c "quit":   exit cleanly after sourcing; non-zero exit on any error
		#
		# We capture the output, strip the noisy store path from the first line
		# (e.g. "Error detected while processing ...script /nix/store/…-content:")
		# and replace it with just the config name so humans can orient themselves.
		''nvim_errors=$(nvim -V1 -es -u NONE -c "source ${contentFile}" -c "quit" 2>&1 || true)''
		''if echo "$nvim_errors" | grep -q "^Error detected"; then''
		''  # Replace the store-path header with a human-readable config name''
		''  clean_errors=$(echo "$nvim_errors" | sed "s|Error detected while processing command line..script [^:]*:|Error detected in '${name}':|")''
		''  echo "$clean_errors"''
		''  echo ""''
		''  echo "Content that failed validation (line numbers match the errors above):"''
		''  echo "--------"''
		''  cat -n "${contentFile}"''
		''  echo ""''
		''  echo "--------"''
		''  exit 1''
		''fi''

		# Check 2: Duplicate set commands
		# Duplicate set commands are legal vimscript but often indicate copy/paste
		# mistakes or conflicting module contributions; warn but do not fail
		''DUPLICATES=$(grep -oP "(?<=^set )[a-zA-Z]+" "${contentFile}" | sort | uniq -d)''
		''if [ -n "$DUPLICATES" ]; then''
		''  echo "WARNING: Duplicate set commands in ${name}:"''
		''  echo "$DUPLICATES"''
		''fi''

		# Check 3: Numeric option sanity
		# tabstop and shiftwidth values above 20 are almost certainly mistakes
		# and cause visual distortion; warn but do not fail
		''TS=$(grep -oP "(?<=set tabstop=)[0-9]+" "${contentFile}" | tail -1)''
		''if [ -n "$TS" ] && [ "$TS" -gt 20 ]; then''
		''  echo "WARNING: tabstop=${"\${TS}"} in ${name} is > 20 and may cause display issues"''
		''fi''
		''SW=$(grep -oP "(?<=set shiftwidth=)[0-9]+" "${contentFile}" | tail -1)''
		''if [ -n "$SW" ] && [ "$SW" -gt 20 ]; then''
		''  echo "WARNING: shiftwidth=${"\${SW}"} in ${name} is > 20 and may cause display issues"''
		''fi''

		# Check 4: Risky options
		# These are valid options but can cause surprising behaviour; inform only
		''if grep -q "set spell" "${contentFile}"; then''
		''  echo "NOTE: spell checking enabled in ${name} (may affect startup performance)"''
		''fi''
		''if grep -q "set scrollbind" "${contentFile}"; then''
		''  echo "NOTE: scrollbind enabled in ${name} (can cause scroll-sync surprises)"''
		''fi''

		# All checks passed — the output is the validated content file
		''echo "mkVimConfig: all checks passed for ${name}"''
		''cp "${contentFile}" "$out"''
	]);

in
	readFile validated
