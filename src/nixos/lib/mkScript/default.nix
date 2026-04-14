###! # mkScript — NiXium replacement for pkgs.writeShellApplication
###!
###! SUMMARY: mkScript — create a derivation that installs a shell-based program
###! with ksh93 as the default runtime shell, build-time shellcheck linting,
###! and shfmt-based minification enabled by default to optimize the embedded
###! script size. The library exposes mkScript.defaults for callers to
###! explicitly reference and compose canonical defaults.
###!
###! ## WHY THIS FILE EXISTS
###!
###! NiXium previously used `pkgs.writeShellApplication` across many modules
###! (mkVM runner, autologin scripts, start scripts). Upstream's helper is
###! bash-centric and lacks opinionated defaults NiXium needs (ksh by default,
###! build-time shfmt minification, NiXium-specific shellcheck exclusions,
###! documented defaults that callers can programmatically reference).
###!
###! This library is a replacement (NOT a thin wrapper) for writeShellApplication.
###! By design mkScript performs the following behaviors by default: it uses
###! ksh93 as the runtime shell (PATH-based exec, and the default
###! runtimeInputs include pkgs.ksh93), it runs shellcheck against the
###! original author-provided source before any minification (safety-first),
###! and it performs shfmt-based minification by default with the canonical
###! flags `-s -mn` to reduce the embedded script size in the produced
###! derivation. The library exposes mkScript.defaults so call sites can
###! explicitly derive values using Nix lib helpers (++, lib.filter, lib.remove)
###! rather than relying on implicit merging of lists.
###!
###! ## PUBLIC API: mkScript
###!
###! mkScript is the ONLY public function exported by this file. It returns
###! a single derivation: an executable installed at `/bin/${name}`. The
###! derivation is suitable for use in systemd ExecStart, apps, packages, and
###! checks (nix flake check). The function also exposes `mkScript.defaults`
###! as an attrset containing canonical defaults.
###!
###! ## RETURN VALUE
###!
###! The function returns a `stdenv.mkDerivation`-style derivation that produces
###! an output with `/bin/${name}` containing the generated script. The
###! derivation's `checkPhase` runs linting (shellcheck) and validation hooks
###! so builds fail early when scripts are invalid.
###!
###! ## WHY THIS DESIGN
###!
###! - ksh93 is the reference POSIX implementation and supports string
###!   replacement/indexing and other maintainability features that NiXium
###!   intentionally permits (see .shellcheckrc disables).
###! - Running shellcheck before minification prevents hiding lint directives
###!   and ensures developer-authored source is validated.
###! - shfmt -s -mn performs AST-aware minification (safe) and yields
###!   substantial size savings without brittle regex transforms.
###!
###! ## PARAMETERS
###!
###! The function accepts the following parameters (Nix-style):
###!
###! name (String) — required
###!   The binary name to install under /bin (and systemd ExecStart target).
###!
###! text (String) — required
###!   The script body. This should NOT include a shebang. Prefer
###!   concatStringsSep "\n" for multi-line content at call sites.
###!
###! runtimeInputs ? [ pkgs.ksh93 ]
###!   List of packages whose bin/ paths are added to PATH at runtime. Default
###!   includes pkgs.ksh93 so `ksh` is available on PATH for the PATH-based
###!   exec. If caller supplies runtimeInputs, it replaces the default — callers
###!   who want to extend can use `mkScript.defaults.runtimeInputs ++ [...]`.
###!
###! runtimeEnv ? null
###!   Attrset of environment variables to hard-assign into the script at
###!   runtime. Use the `_DEFAULT` suffix pattern for values that should be
###!   overridable at runtime (see mkVM runtimeEnv examples).
###!
###! shellOptions ? mkScript.defaults.shellOptions
###!   List of shell options to enable. Default is the NiXium safe set. If the
###!   caller provides a value it REPLACES the default (no implicit merging).
###!
###! excludeShellChecks ? mkScript.defaults.excludeShellChecks
###!   List of ShellCheck checks to exclude by default. Replacement semantics —
###!   callers should explicitly derive from mkScript.defaults to add/remove.
###!
###! extraShellCheckFlags ? []
###!   Additional CLI flags passed to shellcheck.
###!
###! checkPhase ? null
###!   Optional override for the checkPhase. By default mkScript configures a
###!   checkPhase that performs a syntax dry-run and runs shellcheck against the
###!   ORIGINAL author source before any minification occurs. This default
###!   checkPhase executes during the derivation build (for example when you
###!   run `nix build` or `nix flake check`) and ensures failures are caught and
###!   reported as part of the build/check pipeline. Callers may override the
###!   checkPhase if they have specific needs, but the library strongly
###!   recommends preserving the default safety checks or re-running equivalent
###!   validations in a custom checkPhase.
###!
###! format ? mkScript.defaults.format
###!   Boolean. When true, run shfmt with shfmtOptions in the build to produce
###!   the embedded/minified script. Default `true` to enable size-optimization
###!   by default for mkVM and similar heavy-use scripts.
###!
###! shfmtOptions ? mkScript.defaults.shfmtOptions
###!   List of flags passed to shfmt. Default `-s -mn` (simplify + minify).
###!
###! derivationArgs ? {}
###!   Attrset forwarded to stdenv.mkDerivation for advanced use. Use with
###!   caution — overriding internal attributes can break the derivation.
###!
###! inheritPath ? mkScript.defaults.inheritPath
###!   Boolean controlling whether the generated script will append `:$PATH`
###!   after the generated PATH from runtimeInputs. Default is `false` (hermetic).
###!
###! meta ? {}
###!   Derivation metadata (maintainers, license, description). Keep for
###!   compatibility and package auditing.
###!
###! passthru ? {}
###!   Optional passthru attrset. Keep minimal; we may revisit in a separate
###!   quest for passthru conventions across mk* libraries.
###!
###! ### Defaults exposed (mkScript.defaults)
###!
###! mkScript.defaults = {
###! 	shellOptions = [ "errexit" "nounset" "pipefail" "posix" ];
###! 	excludeShellChecks = [ "SC3060" "SC3057" "SC3001" ];
###! 	shfmtOptions = [ "-s" "-mn" ];
###! 	format = true;
###! 	inheritPath = false;
###! 	runtimeInputs = [ pkgs.ksh93 ];
###! };
###!
###! ## BUILD-TIME BEHAVIOR (exact steps)
###!
###! 1) Linting phase (pre-format):
###!    - The checkPhase runs shellcheck against the original `text` provided by
###!      the caller. This ensures developer-authored source is validated and
###!      any shellcheck directives present in the source are effective.
###!    - Use `excludeShellChecks` + `extraShellCheckFlags` when constructing the
###!      shellcheck command line.
###!
###! 2) Formatting / minification (format = true by default):
###!    - After the pre-format lint step completes successfully, the build runs
###!      `shfmt` with `shfmtOptions` to produce the embedded script. The
###!      primary behavior of mkScript is to minify the embedded script by
###!      default; callers who prefer the original formatting may opt out by
###!      setting `format = false`.
###!    - Default `shfmtOptions` are `-s -mn` which perform AST-aware
###!      simplification and semantic minification in a safe manner.
###!    - NOTE: shellcheck is run against the original source in step 1 — do
###!      not rely on shellcheck of the minified output because comments and
###!      pragmas are removed by minification.
###!
###! 3) Script assembly:
###!    - Construct the runtime script text as concatenation of:
###!      a) `#!` shebang is NOT injected here; we use a PATH-based exec wrapper
###!         or install the script as an executable whose first line runs `exec ksh`.
###!      b) A `set` line constructed from `shellOptions` (e.g., `set -o errexit` or
###!         `set -euo pipefail` depending on options present). These options are
###!         always explicitly set by the generated script to avoid relying on
###!         caller shells.
###!      c) `runtimeEnv` block (if non-null) converted with `lib.toShellVar` and
###!         exported. For overridable values use `_DEFAULT` suffix pattern.
###!      d) PATH export using `lib.makeBinPath runtimeInputs` and append `:$PATH`
###!         only if `inheritPath = true`.
###!      e) The (minified) `text` from step 2 or the original `text` if
###!         `format = false`.
###!
###! 4) Final derivation:
###!    - Build a `stdenv.mkDerivation` producing an executable at `/bin/${name}`.
###!    - checkPhase is the step that runs the linting described above and the
###!      `stdenv.shellDryRun` validation.
###!
###! 5) Packaging notes:
###!    - The derivation prefers PATH-based exec (`exec ksh`) instead of
###!      hardcoding absolute interpreter paths. `runtimeInputs` default ensures
###!      `ksh` is available on PATH unless caller overrides.
###!
###! ## SAFETY AND LINTING
###!
###! - **MUST** run shellcheck on the original source. Minification removes
###!   comments and pragmas — running shellcheck after minification hides
###!   developer intent and may produce false-positives/negatives.
###! - **MUST** preserve `###!` spec comments in the repository source. These
###!   comments are the canonical spec and should not be stripped by minification
###!   of the built artifact (the built artifact can drop them; the source file
###!   in the repo remains the canonical spec).
###! - **MUST** respect .shellcheckrc. The library's checkPhase should apply the
###!   project's shellcheck disables by default (mkScript.defaults.excludeShellChecks)
###!   but callers can override.
###!
###! ## SHFMT FLAGS (Rationale)
###!
###! The default shfmt flags are `-s -mn`. Brief explanation for readers so
###! you don't need to consult man pages:
###!
###! - `-s` (simplify): perform semantics-preserving simplifications where
###!   possible. Examples: simplify certain conditional constructs, remove
###!   redundant constructs, and prefer shorter equivalent forms where the
###!   transformation is semantics-preserving. This reduces byte size and
###!   often improves clarity of the canonical form.
###!
###! - `-mn` (minify): instruct shfmt to produce a minimized representation of
###!   the script where safe. This collapses non-significant whitespace and
###!   line breaks and removes comments/pragmas from the embedded script; the
###!   result is the most compact semantics-preserving form shfmt can produce.
###!
###! NOTE: Because `-mn` removes comments and pragmas, mkScript runs
###! `shellcheck` against the original source before minification (the
###! pre-format checkPhase) so developer-supplied pragmas remain effective for
###! validation.
###!
###! ## EXAMPLES
###!
###! Basic (default minification + ksh):
###!
###! ```nix
###! let mkScript = import ./mkScript { inherit lib pkgs stdenv; };
###! in mkScript {
###! 	name = "my-tool";
###! 	text = concatStringsSep "\n" [
###! 		'echo "Running my-tool"'
###! 		'cmd --do-thing'
###! 	];
###! };
###! ```
###!
###! Extend excludeShellChecks:
###!
###! ```nix
###! mkScript {
###! 	name = "my-tool";
###! 	text = builtins.readFile ./tool.sh;
###! 	excludeShellChecks = mkScript.defaults.excludeShellChecks ++ [ "SC2086" ];
###! };
###! ```
###!
###! Remove a default shellOption (example uses lib.filter):
###!
###! ```nix
###! mkScript {
###! 	name = "tricky";
###! 	text = builtins.readFile ./tricky.sh;
###! 	shellOptions = lib.filter (o: o != "pipefail") mkScript.defaults.shellOptions;
###! };
###! ```
###!
###! ## MIGRATION PLAN (mkVM)
###!
###! 1. Implement mkScript and expose mkScript.defaults.
###! 2. Run CI builds of mkVM with the runner using mkScript (format = true)
###!    and ensure shellcheck passes on the original runner.sh.
###! 3. Replace `pkgs.writeShellApplication` call sites in mkVM (mkVmRunner,
###!    mkXorgKioskModule, mkCliAutologinModule) with mkScript invocations.
###! 4. Replace `exec bash` uses with `exec ksh` in runner scripts where
###!    appropriate, ensuring runtimeInputs include ksh93.
###! 5. Run VM tests (`nix build .#nixosConfigurations...vm`) and integration
###!    validation. Fix any shfmt/shellcheck issues discovered.
###!
###! ## TESTING & VALIDATION
###!
###! - Unit: Build mkScript with a simple script and ensure derivation builds.
###! - Lint: Confirm shellcheck runs and fails the build if the original source
###!   contains safety issues.
###! - Format: Confirm shfmt runs and produced script is syntactically valid
###!   (use `stdenv.shellDryRun` / `ksh -n` if available in checkPhase).
###! - Integration: Use mkVM runner to exercise the generated runner in a VM.
###!
###! ## SECURITY & MAINTAINABILITY CONSIDERATIONS
###!
###! - `runtimeEnv` is appropriate for non-secret runtime configuration. Do
###!   NOT place secrets in plain text in the `text` parameter or in build-time
###!   `runtimeEnv` values. Use age/ragenix (ragenix) for secret management and
###!   reference secrets explicitly via the secret management API where
###!   appropriate. If you must reference an age secret produced by a NixOS
###!   configuration, be explicit about whether you are referencing the
###!   encrypted source file (repo artifact) or a runtime-decrypted path
###!   (e.g. `/run/agenix/...`); avoid baking plaintext secrets into other
###!   derivations or artifacts.
###!
###! Example — allowed patterns vs bad patterns
###!
###! # Good: reference the encrypted artifact in the repo (build-time reference)
###! secretSource = self.nixosConfigurations.nixos-sinnenfreude-stable.config.age.secrets.sinnenfreude-disks-password.file;
###!
###! # Good (runtime): reference the runtime-decrypted path exposed by agenix
###! secretRuntimePath = self.nixosConfigurations.nixos-sinnenfreude-stable.config.age.secrets.sinnenfreude-disks-password.path;
###! # At runtime the script may read from $secretRuntimePath after agenix
###! # has decrypted it (ensure ordering / activation guarantees are documented).
###!
###! # Bad: embedding plaintext secrets in runtimeEnv or inlined text
###! # runtimeEnv = { DISK_PASS = "hunter2"; };    # BAD — plaintext secret
###! # text = concatStringsSep "\n" [ "PASSWORD=hunter2" "do_stuff" ];    # BAD
###!
###! - Keep the repo source authoritative — the built/minified script is a
###!   derived artifact and may be less readable; always consult the `###!`
###!   spec comments and source files in the repo for maintainability.
###!
###! - Avoid adding new shellcheck disables without a formal justification in
###!   the `###!` spec or a linked issue/quest.
###!
###! ## IMPLEMENTATION NOTES FOR THE DEVELOPER
###!
###! - Use tabs for indentation in this Nix file (project standard).
###! - Use `concatStringsSep "\n"` to assemble multi-line script fragments.
###! - Always `git add` new files before attempting to build locally so Nix
###!   evaluation can find the sources.
###! - Provide a README snippet and example call sites to aid reviewers.
###!
###! <!-- End of mkScript spec -->

{ lib, pkgs, stdenv, shellcheck, shfmt, ksh }:

let
	defaults = {
		shellOptions = [ "errexit" "nounset" "pipefail" "posix" ];
		excludeShellChecks = [ "SC3060" "SC3057" "SC3001" ];
		shfmtOptions = [ "-s" "-mn" ];
		format = true;
		inheritPath = false;
		runtimeInputs = [ pkgs.ksh93 ];
	};

	mkScript = args@{
		name,
		text,
		runtimeInputs ? defaults.runtimeInputs,
		runtimeEnv ? null,
		shellOptions ? defaults.shellOptions,
		excludeShellChecks ? defaults.excludeShellChecks,
		extraShellCheckFlags ? [],
		checkPhase ? null,
		format ? defaults.format,
		shfmtOptions ? defaults.shfmtOptions,
		derivationArgs ? {},
		inheritPath ? defaults.inheritPath,
		meta ? {},
		passthru ? {},
	}: let
		# Create a build-time source file containing the original author text so
		# the checkPhase can validate the original content. This is a pure
		# writeTextFile derivation; it does not execute external tools at eval.
		source = pkgs.writeTextFile {
			name = "${name}-source";
			text = text;
		};

		# Helper: build the set - line from shellOptions
		setLine = let
			partsList = lib.filter (v: v != "") [
				(if lib.elem "errexit" shellOptions then "-e" else "")
				(if lib.elem "nounset" shellOptions then "-u" else "")
				(if lib.elem "pipefail" shellOptions then "-o pipefail" else "")
			];
			parts = lib.concatStringsSep " " partsList;
		in if parts == "" then "" else "set " + parts;

		# Construct shellcheck command flags
		excludeFlags = lib.optionals (excludeShellChecks != []) [
			"--exclude"
			(lib.concatStringsSep "," excludeShellChecks)
		];

		# get exe paths
		shellcheckExe = "${shellcheck}/bin/shellcheck";
		shfmtExe = "${shfmt}/bin/shfmt";

		# The default checkPhase validates original source: syntax check + shellcheck
		defaultCheck = ''
		runHook preCheck
		# Syntax dry-run using ksh
		${ksh}/bin/ksh -n "${source}"
		# Run shellcheck on the original source
		${shellcheckExe} ${lib.concatStringsSep " " (excludeFlags ++ extraShellCheckFlags)} "${source}"
		runHook postCheck
		'';

		# installPhase builds the final executable at $out/bin/${name}
		install = ''
		mkdir -p $out/bin
		# Shebang: use env-based ksh to respect runtimeInputs
		echo '#!/usr/bin/env ksh' > $out/bin/${name}
		# Set shell options if any
		${lib.optionalString (setLine != "") (''echo '${setLine}' >> $out/bin/${name}'' )}
		# runtimeEnv exports
		${lib.optionalString (runtimeEnv != null) (lib.concatMapAttrsStringSep "\n" (var: val: ''${lib.toShellVar var val}
		export ${var}'') runtimeEnv)}
		# PATH export from runtimeInputs
		echo "export PATH=\"${lib.makeBinPath runtimeInputs}${lib.optionalString inheritPath ":$PATH"}\"" >> $out/bin/${name}
		# Append script body: either shfmt-minified or original
		${if format then
			''
			# run shfmt on the original source and append
			${shfmtExe} ${lib.concatStringsSep " " shfmtOptions} "${source}" >> $out/bin/${name}
			''
		else
			''
			cat "${source}" >> $out/bin/${name}
			''}
		chmod +x $out/bin/${name}
		'';

	in stdenv.mkDerivation (lib.mkMerge [ {
		name = "${name}";
		doInstallCheck = true;
		nativeBuildInputs = [ shellcheck shfmt ksh ];
		buildInputs = runtimeInputs;
		src = source;
		checkPhase = if checkPhase == null then defaultCheck else checkPhase;
		installPhase = install;
		meta = meta;
		passthru = passthru;
		inherit (derivationArgs) inheritPath;
	} derivationArgs ]);

in
	# Attach defaults and return the function
	(lib.recursiveUpdate mkScript { defaults = defaults; })
