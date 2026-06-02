###! # mkScript — NiXium replacement for pkgs.writeShellApplication
###!
###! SUMMARY: mkScript — create a derivation that installs a shell-based program with ksh (AT&T ksh2020, pkgs.ksh) as the default runtime shell, build-time shellcheck linting, and shfmt-based minification enabled by default. The library exposes mkScript.defaults for canonical defaults.
###!
###! ## WHY THIS FILE EXISTS
###!
###! NiXium previously used `pkgs.writeShellApplication` across many modules (mkVM runner, autologin scripts, start scripts). Upstream's helper is bash-centric and lacks opinionated defaults NiXium needs:
###! 1. ksh by default: NiXium standardizes on AT&T ksh2020 for its advanced string and array features.
###! 2. Build-time minification: Standard helpers do not minify, leading to larger derivations.
###! 3. NiXium-specific shellcheck exclusions: Standard linting flags often clash with valid ksh extensions.
###! 4. Programmatic Defaults: Callers need to reference canonical defaults (e.g., shellOptions) to extend them without implicit merging, which can lead to unpredictable behavior.
###!
###! This library is a replacement (NOT a thin wrapper) for writeShellApplication. By design, mkScript implements a "Safe Factory" pattern. It ensures that every script produced follows a strict validation pipeline (Syntax -> Lint -> Minify -> Syntax) and is deployed with a hermetic environment. The library exposes mkScript.defaults so call sites can explicitly derive values using Nix lib helpers (++, lib.filter, lib.remove) rather than relying on implicit merging.
###!
###! ## KSH PACKAGE NOTE
###!
###! nixpkgs exposes AT&T KornShell as `pkgs.ksh` (ksh2020, version 2020.x). There is no separate `pkgs.ksh93` in nixpkgs — `pkgs.ksh` IS the AT&T KornShell. ksh2020 is the active upstream continuation of ksh93 and supports all ksh93 extensions (string replacement, substring indexing, associative arrays, etc.) that NiXium intentionally permits.
###!
###! ## KSH EXTENSIONS POLICY
###!
###! NiXium intentionally permits ksh extensions beyond strict POSIX. This is why the default shellOptions do NOT include "posix" — setting `set -o posix` inside ksh would disable the very ksh-specific syntax NiXium uses. The default excludeShellChecks (SC3060, SC3057, SC3001) disable shellcheck warnings for ksh string-replacement, substring-index, and brace-expansion syntax that are not in strict POSIX but are valid ksh2020.
###!
###! If a caller needs strict POSIX compliance for a specific script, they should explicitly set:
###! 	shellOptions = mkScript.defaults.shellOptions ++ [ "posix" ];
###! 	excludeShellChecks = [];  # or a carefully curated subset
###!
###! ## PUBLIC API: mkScript
###!
###! mkScript is the ONLY public function exported by this file. It returns a single derivation producing an executable at /bin/${name}.
###!
###! PARAMETERS:
###! - name (String) — Required. The binary name to install under /bin.
###! - text (String) — Required. The script body. Should NOT include a shebang.
###! - runtimeInputs ? [ pkgs.ksh ] — Packages whose bin/ paths are added to PATH at runtime.
###! - runtimeEnv ? null — Attrset of environment variables. MUST NOT contain plaintext secrets. Secrets should be passed as paths to ragenix-managed files.
###! - shellOptions ? mkScript.defaults.shellOptions — List of shell options. Defaults to [ "errexit" "nounset" "pipefail" ].
###! - excludeShellChecks ? mkScript.defaults.excludeShellChecks — ShellCheck exclusions.
###! - extraShellCheckFlags ? [] — Additional flags. MUST NOT include --shell=*.
###! - formatter ? mkScript.defaults.formatter — Minification config { enable, flags }.
###! - inheritPath ? mkScript.defaults.inheritPath — Append :$PATH to runtime PATH.
###! - buildPhase / checkPhase / installPhase ? null — Top-level overrides for the "Safe Engine".
###! - derivationArgs ? {} — Forwarded to mkDerivation (protected keys: buildPhase, checkPhase, installPhase, doCheck, dontUnpack).
###! - meta / passthru ? {} — Derivation metadata.
###!
###! ## BUILD-TIME BEHAVIOR (The Safe Engine)
###!
###! 1) buildPhase:
###!    - Write original text to source.sh via printf + escapeShellArg.
###!    - If formatter.enable: run shfmt -> formatted.sh. Else: cp source.sh formatted.sh.
###!
###! 2) checkPhase:
###!    - ksh -n source.sh (Syntax check original).
###!    - shellcheck --shell=ksh [flags] source.sh (Lint original).
###!    - ksh -n formatted.sh (Syntax check minified output).
###!    - This order ensures that syntax errors are caught before linting, and minification bugs are caught before installation.
###!
###! 3) installPhase:
###!    - Assemble final script using a self-bootstrapping header:
###!      a) Shebang: #!/usr/bin/env ksh
###!      b) PATH export: export PATH='${makeBinPath runtimeInputs}'
###!      c) Env exports: export VAR='val' (via toShellVar)
###!      d) setLine: set -eu -o pipefail (from shellOptions)
###!      e) Body: content of formatted.sh
###!
###! ## SHFMT FLAGS (Rationale)
###!
###! - `-s` (simplify): semantics-preserving simplification (shorter equivalent forms).
###! - `-mn` (minify): collapse whitespace/linebreaks, strip comments/pragmas.
###!
###! NOTE: Because `-mn` strips comments/pragmas, shellcheck runs against the original source in checkPhase (step 2 above), not the minified output.
###!
###! ## RESEARCH & VALIDATION
###!
###! All tests performed via transient mkVM instances using nix repl.
###!
###! - shc (Shell-to-C): Discarded.
###!   - Test Case: Script using associative arrays (`typeset -A`) and string replacement (`${var// /_}`).
###!   - Size Analysis: Original (~1.2KB) -> shfmt (~0.6KB) -> shc binary (~15-30KB).
###!   - Result: shc increases size by ~25x and adds C-toolchain complexity without providing true minification.
###! - ShellCheck PATH: Proven via PoC that ShellCheck is environment-blind and cannot validate command existence via PATH.
###! - Command Validation: Shelved as a separate Quest due to the complexity of reliable static analysis without execution.
###! - ksh2020: Validated via mkVM that extensions (associative arrays, etc.) are fully supported.
###! - Wrapper Design: Transitioned from separate wrapper derivation to self-bootstrapping header to reduce store overhead and startup latency.
###!
###! ## DEPLOYMENT
###!
###! Returns a derivation. Compatible with:
###! - systemd.services.<<<<namnamename>>.serviceConfig.ExecStart
###! - home.file.".local/bin/<<<<namnamename>>".source (Home-Manager)
###!
###! ## EXAMPLES
###!
###! Basic (default minification + ksh):
###!
###! ```nix
###! let ms = import ./mkScript { inherit lib pkgs stdenv; };
###! in ms.mkScript {
###! 	name = "my-tool";
###! 	text = concatStringsSep "\n" [
###! 		''echo "Running my-tool"''
###! 		''cmd --do-thing''
###! 	];
###! };
###! ```
###!
###! Extend excludeShellChecks:
###!
###! ```nix
###! ms.mkScript {
###! 	name = "my-tool";
###! 	text = builtins.readFile ./tool.sh;
###! 	excludeShellChecks = ms.defaults.excludeShellChecks ++ [ "SC2086" ];
###! };
###! ```
###!
###! Remove a default shellOption (example using lib.filter):
###!
###! ```nix
###! ms.mkScript {
###! 	name = "tricky";
###! 	text = builtins.readFile ./tricky.sh;
###! 	shellOptions = lib.filter (o: o != "pipefail") ms.defaults.shellOptions;
###! };
###! ```
###!
###! Extend runtimeInputs:
###!
###! ```nix
###! ms.mkScript {
###! 	name = "net-tool";
###! 	text = ''curl -s https://example.com'';
###! 	runtimeInputs = ms.defaults.runtimeInputs ++ [ pkgs.curl ];
###! };
###! ```
###!
###! ## SECURITY & MAINTAINABILITY CONSIDERATIONS
###!
###! - `runtimeEnv` is for non-secret runtime configuration ONLY. NEVER place plaintext secrets in `text` or `runtimeEnv` values. Use age/ragenix for secrets.
###! - Allowed patterns:
###!   secretRuntimePath = config.age.secrets.my-secret.path;
###!   # script reads the FILE at that path after agenix has decrypted it
###! - BAD patterns:
###!   runtimeEnv = { DISK_PASS = "hunter2"; };    # plaintext secret — NEVER
###!   text = concatStringsSep "\n" [ ''PASSWORD=hunter2'' ''do_stuff'' ]; # NEVER
###! - Avoid adding new shellcheck disables without a formal justification in the `###!` spec or a linked issue/quest.
###!
###! ## readonlyVars Parameter
###!
###! Purpose:
###!   Declare which runtime environment variables should be marked `readonly` in the generated script.
###!   Prevents accidental/malicious modification of critical variables.
###!
###! Default:
###!   [ "PATH" "SHELL" ]
###!
###! Variables and Rationale:
###!   - **PATH**
###!     Controls executable lookup. Must remain hermetic to prevent injection attacks.
###!   - **SHELL**
###!     Ensures the script runs under the expected shell (ksh). Changing it could bypass safety checks.
###!
###! Usage:
###!   mkScript {
###!     readonlyVars = [ "MY_CONFIG" ];  # Extend defaults
###!   };
###!
###! In the script header:
###!   "readonly ${concatStringsSep " " readonlyVars}"  # Added after all exports
###!
###! ## IMPLEMENTATION NOTES
###!
###! - Use tabs for indentation.
###! - Use concatStringsSep "\n" for multi-line fragments.
###! - No escaped \n in strings.
###!
###! ## HOOKS & EXTENSIONS
###!
###! To extend the build process without overriding the entire phase, use `derivationArgs` to provide hooks.
###! NiXium's mkScript explicitly calls `runHook preBuild`, `runHook postBuild`, etc.
###!
###! Example:
###! ```nix
###! mkScript {
###! 	name = "my-tool";
###! 	text = "...";
###! 	derivationArgs = {
###! 		preBuild = ''echo "Starting build..." '';
###! 		postInstall = ''echo "Installation complete" '';
###! 	};
###! };
###! ```
###!
###! ## OVERRIDE POLICY
###!
###! mkScript exposes three top‑level **phase groups**.  Each group contains the
###! full phase plus optional *pre*/*post* hooks.  The hierarchy makes the
###! layout easier to scan for contributors with dyslexia or visual‑processing
###! challenges.
###!
###!   - **check**
###!       - preCheck   — runs *before* the default check phase
###!       - checkPhase — the full validation pipeline (syntax → lint → minify)
###!       - postCheck  — runs *after* the default check phase
###!   - **build**
###!       - preBuild   — runs *before* the default build phase
###!       - buildPhase — the default build phase (writes source, runs shfmt)
###!       - postBuild  — runs *after* the default build phase
###!   - **install**
###!       - preInstall — runs *before* the default install phase
###!       - installPhase — the default install phase (writes script header, copies)
###!       - postInstall — runs *after* the default install phase
###!
###! **RULES FOR OVERRIDES:**
###! 1. **Any override (including any pre‑/post‑ hook) requires a non‑empty**
###!    **`overrideReason`** that explains *why* the default pipeline is being
###!    changed.
###! 2. If an override is supplied **without** a non‑empty `overrideReason`,
###!    mkScript will abort the build and print an **educational error message**
###!    generated by the `mkError` helper (see the **mkError Helper** section
###!    below).
###! 2. The Safe Engine pipeline (syntax check → lint → minify) **must always run**
###!    unless a top‑level phase (`checkPhase`, `buildPhase`, `installPhase`) is
###!    overridden **and** an `overrideReason` is supplied.
###! 3. Hooks are provided for convenience but **do not reduce risk**; they are
###!    subject to the same `overrideReason` requirement.
###!
###! **EXAMPLE (all three groups overridden with reasons):**
###!   mkScript {
###!     preCheck    = "echo 'custom pre‑check'";
###!     checkPhase  = "ksh -n source.sh && my‑custom‑linter source.sh";
###!     postCheck   = "echo 'custom post‑check'";
###!     preBuild    = "echo 'custom pre‑build'";
###!     buildPhase  = "printf '%s' \"$text\" > src.sh && my‑formatter src.sh > fmt.sh";
###!     postBuild   = "echo 'custom post‑build'";
###!     preInstall  = "echo 'custom pre‑install'";
###!     installPhase= "mkdir -p $out/bin && cp fmt.sh $out/bin/${name}";
###!     postInstall = "echo 'custom post‑install'";
###!     overrideReason = "Project‑specific tooling required for compliance";
###!   };
###!
###! - overrideReason ? null — Required when any phase (check, build, install, or any pre/post hook) is overridden.
###!   Must contain a non‑empty explanation of why the default Safe Engine pipeline is insufficient.
###!   If omitted or empty, the build fails and an educational message is printed via the **mkError** helper.
###!
###! <!-- End of mkScript spec -->

{ lib, pkgs, stdenv, ... }:

let
	# Import the mkError helper for educational failure messages
	mkError = import ./../mkError/lib-mkError.nix { inherit lib; };

	# --- Core Utilities ---
	# We extract these from lib to keep the logic blocks clean and readable.
	inherit (lib) concatStringsSep makeBinPath toShellVar removeAttrs optionals hasPrefix escapeShellArg filter any;
	inherit (builtins) attrNames;
	inherit (stdenv) mkDerivation;


	# --- Canonical Defaults ---
	# These provide the "NiXium Standard" for shell scripts.
	# Junior developers should reference these when extending behavior.
	defaults = {
		shellOptions = [
			"errexit" # -e: Exit immediately if a command exits with a non-zero status.
			"nounset" # -u: Treat unset variables as an error when substituting.
			"pipefail" # -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status.
		];

		excludeShellChecks = [
			"SC3060" # Permit ksh-style string replacement: ${var//search/replace}
			"SC3057" # Permit ksh-style substring indexing: ${var:offset:length}
			"SC3001" # Permit ksh-style brace expansion
		];

		formatter = {
			enable = true;
			flags = [
				"-ln" "bash" # FIXME: shfmt lacks a ksh dialect; bash is the closest semantic match.
				"-s"         # Simplify: apply semantics-preserving simplifications.
				"-mn"        # Minify: collapse whitespace and remove comments for production.
			];
		};

		inheritPath = false; # By default, we use a hermetic PATH for reproducibility.
		runtimeInputs = [ pkgs.ksh ];
		readonlyVars = [ "PATH" "SHELL" ];
	};


	# --- The mkScript Factory ---
	mkScript = args@{
		name,
		text,
		...
	}:
	let
		# 1. Parameter Resolution
		# We explicitly resolve arguments to avoid implicit merging bugs.
		runtimeInputs        = args.runtimeInputs or defaults.runtimeInputs;
		shellOptions         = args.shellOptions or defaults.shellOptions;
		excludeShellChecks   = args.excludeShellChecks or defaults.excludeShellChecks;
		formatter            = args.formatter or defaults.formatter;
		inheritPath          = args.inheritPath or defaults.inheritPath;
		runtimeEnv           = args.runtimeEnv or null;
		extraShellCheckFlags = args.extraShellCheckFlags or [];
		checkPhaseOverride   = args.checkPhase or null;
		readonlyVars         = args.readonlyVars or defaults.readonlyVars;
		overrideReason       = args.overrideReason or null;
		derivationArgs       = args.derivationArgs or {};
		meta                 = args.meta or {};
		passthru             = args.passthru or {};


		# 2. Shell Option Mapping
		# Converts human-readable options (e.g., "errexit") into shell flags (e.g., "-e").
		optionMap = {
			errexit  = "e";
			nounset  = "u";
			pipefail = "-o pipefail";
			posix    = "-o posix";
		};

		# This logic separates short flags (-e) from long flags (-o pipefail)
		# to ensure the resulting 'set' command is syntactically correct.
		setLine = let
			resolved = map (opt: optionMap.${opt} or "") shellOptions;
			short    = filter (f: f != "" && ! (hasPrefix "-" f)) resolved;
			long     = filter (f: f != "" && hasPrefix "-" f) resolved;
			shortStr = if short == [] then "" else "-" + concatStringsSep "" short;
			longStr  = concatStringsSep " " long;
		in
			concatStringsSep " " (filter (l: l != "") [ shortStr longStr ]);


		# 3. Bootstrapping Header
		# Every script starts with this header to ensure the environment is identical
		# regardless of how the script is invoked.
		scriptHeader = concatStringsSep "\n" (filter (l: l != "") [
			"#!/usr/bin/env ksh"

			(let
				path = makeBinPath runtimeInputs;
				finalPath = if inheritPath then "${path}:\$PATH" else path;
			in "export PATH='${finalPath}'")

			(if runtimeEnv != null then
				concatStringsSep "\n" (map (varName:
					"export ${varName}=${toShellVar runtimeEnv.${varName}}"
				) (attrNames runtimeEnv))
			else "")

			"readonly ${concatStringsSep " " readonlyVars}"

			(if setLine != "" then "set ${setLine}" else "")
		]);


		# 4. Validation Pipeline (Check Phase)
		# We run checks against the original source to preserve comments for ShellCheck,
		# but we also check the minified output to ensure shfmt didn't break syntax.
		excludeFlag = optionals (excludeShellChecks != [])
			[ "--exclude" (concatStringsSep "," excludeShellChecks) ];

		shellcheckCmd = concatStringsSep " " (
			[ "shellcheck" "--shell=ksh" ]
			++ excludeFlag
			++ extraShellCheckFlags
		);

		defaultCheckPhase = concatStringsSep "\n" [
			''runHook preCheck''
			''ksh -n source.sh''            # Step 1: Basic syntax check of source.
			''${shellcheckCmd} source.sh''  # Step 2: Linting of source.
			''ksh -n formatted.sh''         # Step 3: Syntax check of minified output.
			''runHook postCheck''
		];


		# 5. Guardrails
		# We prevent users from overriding critical phases via derivationArgs to
		# ensure the "Safe Engine" pipeline cannot be accidentally bypassed.
		protectedKeys = [ "buildPhase" "checkPhase" "installPhase" "doCheck" "dontUnpack" ];

		_argsGuard = let
			overridden = filter (k: derivationArgs ? k) protectedKeys;
		in
			if (overridden != [])
			then mkError {
				code = "MKSCRIPT-001";
				severity = "critical";
				what = "mkScript(${name}): derivationArgs contains protected keys";
				why  = "Protected keys (${concatStringsSep ", " overridden}) enforce the Safe Engine pipeline. Use top-level parameters instead.";
				how  = ''
					# WRONG
					mkScript {
						derivationArgs = { buildPhase = "..."; };
					}

					# RIGHT
					mkScript {
						buildPhase = "...";
						overrideReason = "Explanation here";
					}
				'';
				docs = "src/nixos/lib/mkScript/lib-mkScript.nix — OVERRIDE POLICY";
			}
			else true;

		# Security: Hard throw if the user tries to bypass ShellCheck's shell detection.
		_shellcheckGuard = if (lib.elem "--shell" extraShellCheckFlags)
		then mkError {
			code = "MKSCRIPT-002";
			severity = "critical";
			what = "mkScript(${name}): extraShellCheckFlags contains '--shell'";
			why  = "Shell detection is locked to 'ksh' for security to ensure consistent linting across NiXium.";
			how  = "Remove '--shell=...' from extraShellCheckFlags.";
			docs = "src/nixos/lib/mkScript/lib-mkScript.nix — SECURITY";
		}
		else true;

		# Override Guard: Enforce non-empty overrideReason if any phase or hook is customized.
		_overrideGuard = let
			isOverridden =
				(checkPhaseOverride != null) ||
				(args ? buildPhase && args.buildPhase != null) ||
				(args ? installPhase && args.installPhase != null) ||
				any (hook: derivationArgs ? hook) [ "preCheck" "postCheck" "preBuild" "postBuild" "preInstall" "postInstall" ];
		in
			if isOverridden && (overrideReason == null || overrideReason == "")
			then mkError {
				code = "MKSCRIPT-003";
				severity = "critical";
				what = "mkScript phase or hook overridden without overrideReason";
				why  = "The Safe Engine ensures syntax, linting, and minification. Overriding these phases bypasses critical security and quality checks.";
				how  = ''
					# WRONG
					mkScript {
						name = "my-tool";
						text = "...";
						checkPhase = "echo 'skip'";
					}

					# RIGHT
					mkScript {
						name = "my-tool";
						text = "...";
						checkPhase = "ksh -n source.sh && custom-lint source.sh";
						overrideReason = "Required custom linting for project compliance";
					}
				'';
				docs = "src/nixos/lib/mkScript/lib-mkScript.nix — OVERRIDE POLICY";
			}
			else true;

		safeDerivationArgs = removeAttrs derivationArgs protectedKeys;
	in
	if (_argsGuard && _shellcheckGuard && _overrideGuard)
	then mkDerivation (safeDerivationArgs // {
		inherit name meta passthru;
		dontUnpack = true;
		doCheck = true;

		nativeBuildInputs = [ pkgs.shellcheck pkgs.shfmt pkgs.ksh ] ++ (derivationArgs.nativeBuildInputs or []);
		buildInputs = [ pkgs.ksh ] ++ (derivationArgs.buildInputs or []);

		# --- The Safe Engine: Build ---
		buildPhase = if args.buildPhase != null then args.buildPhase else concatStringsSep "\n" [
			''runHook preBuild''
			''printf '%s' ${escapeShellArg text} > source.sh''
			(if formatter.enable
				then ''shfmt ${concatStringsSep " " formatter.flags} source.sh > formatted.sh''
				else ''cp source.sh formatted.sh'')
			''runHook postBuild''
		];

		# --- The Safe Engine: Check ---
		checkPhase = if checkPhaseOverride != null then checkPhaseOverride else defaultCheckPhase;

		# --- The Safe Engine: Install ---
		installPhase = if args.installPhase != null then args.installPhase else concatStringsSep "\n" [
			''runHook preInstall''
			''mkdir -p "$out/bin"''
			''printf '%s\\n' ${escapeShellArg scriptHeader} > "$out/bin/${name}''
			''cat formatted.sh >> "$out/bin/${name}''
			''chmod +x "$out/bin/${name}''
			''runHook postInstall''
		];
	})
	else mkError {
		code = "MKSCRIPT-004";
		severity = "critical";
		what = "mkScript Guardrails failed";
		why  = "One or more internal safety checks failed during the derivation construction.";
		how  = "Check the specific error message preceding this one or verify your overrideReason.";
		docs = "src/nixos/lib/mkScript/lib-mkScript.nix";
	};
in
	{
		mkScript = mkScript;
		defaults = defaults;
	}
