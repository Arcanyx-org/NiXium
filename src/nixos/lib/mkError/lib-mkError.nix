###! ## mkError Helper Function
###!
###! Purpose:
###!   Produce **educational** error messages to, but not limited to make the code easier to work with for junior developers.
###!   Each message contains:
###!     • **What** went wrong
###!     • **Why** it matters (the safety property that is at risk)
###!     • **How** to fix it (concrete example code)
###!     • **Docs reference** for further reading (optional)
###!
###! Usage:
###!   # In a module that receives the flake’s lib
###!   let
###!     mkError = lib.mkError;
###!   in
###!     throw (mkError { what, why, how, docs })
###!
###! Example (triggered when a protected key is overridden without a reason):
###!   mkError {
###!     what = "derivationArgs contains protected keys";
###!     why  = "These keys enforce the Safe Engine pipeline (syntax check, linting, minification). Overriding them can silently disable critical validation steps.";
###!     how  = ''
###!       # WRONG – no reason supplied, default pipeline is bypassed
###!       mkScript {
###!         derivationArgs = { checkPhase = "echo 'skip checks'"; };
###!       }
###!       # RIGHT – either use hooks (additive) or provide a reason and override
###!       mkScript {
###!         name = "my-tool";
###!         text   = "...";
###!         checkPhase = "ksh -n source.sh && my‑custom‑linter source.sh";
###!         overrideReason = "Custom linter required for proprietary format";
###!       };
###!     '';
###!     docs = "src/nixos/lib/mkScript/default.nix — OVERRIDE POLICY";
###!   }
###!

{ lib, ... }:

let
  inherit (lib) concatStringsSep splitString filter;
in

args @ { what, why, how, code ? null, severity ? null, docs ? null }:
  let
    # Validate required fields are present and non-empty
    _validateInputs = let
      missing = filter (field: args.${field} == null || args.${field} == "") [ "what" "why" "how" ];
    in
      if missing != []
      then throw "mkError: Required fields missing or empty: ${concatStringsSep ", " missing}"
      else true;

    # Format the how section - handle multi-line examples
    formatHow = let
      lines = splitString "\n" how;
    in
      concatStringsSep "\n" (map (line: "    ###! ${line}") lines);

    # Build the error message sections
    messageParts = [
      "###! Error: ${what}"
      ""
      "  ###! Cause: ${why}"
      ""
      "  ###! Solution:"
      (formatHow)
    ] ++ (
      if docs != null && docs != ""
      then [ "" "  ###! See: ${docs}" ]
      else []
    );
  in
  if _validateInputs
  then throw (concatStringsSep "\n" messageParts)
  else ""
