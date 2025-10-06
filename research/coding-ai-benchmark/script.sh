#!/usr/bin/env ksh
# shellcheck shell=ksh
set -euo pipefail

# Neutral Nix prompt for the exam
neutral_prompt=$(cat <<'EOF'
Generate a flake.nix that:
1. Defines two custom packages: "my-lib" (a simple C library) and "my-tool" (a Rust binary depending on my-lib).
2. Uses overlays so that my-tool can use my-lib through an overridden nixpkgs.
3. Provides a devShell that exposes both clang and cargo, with RUST_SRC_PATH set properly.
4. Builds cleanly for both x86_64-linux and aarch64-linux via cross compilation.

Explain in 2-3 paragraphs how Nix's lazy evaluation interacts with fixed-output derivations and why this affects reproducibility with fetchGit.

Correct the following scoping error in Nix expression:
{ pkgs ? import <nixpkgs> {} }:
let
  lib = pkgs.lib;
in
  pkgs.stdenv.mkDerivation {
    name = "demo";
    src = ./src;
    buildPhase = ''
      gcc \$lib.strings.concatStrings ["hello" "world"]
    '';
  }

Extend your flake to expose a formatter output (packages.formatter) that runs alejandra on all .nix files.

Reason about which operations would work or fail if nixpkgs only provided binary caches and no source.
EOF
)

# List of models to benchmark
models='
codellama:7b-instruct
mistral:7b-instruct
starcoder2:7b
deepseek-coder:6.7b-base
qwen2.5-coder:7b-instruct
'

for model in $models; do
    echo "================================================="
    echo "Pulling model: $model"
    echo "================================================="
    ollama pull "$model"

    echo "================================================="
    echo "Dumping model configuration / parameters for $model"
    echo "================================================="
    ollama run "$model" "Please output a JSON object describing your model parameters (temperature, top-p, top-k, max tokens, etc.) and also include the default system prompt that the model uses internally."

    echo "================================================="
    echo "Benchmarking model (exam) for $model"
    echo "================================================="

    # Temporary file for GPU logging
    TMP_GPU=$(mktemp)

    # Start GPU logging in background
    (
      while :; do
        nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
                   --format=csv,noheader
        sleep 1
      done
    ) >"$TMP_GPU" &
    GPU_PID=$!

    # Run AI model with CPU/memory metrics
    perf stat -e cycles,instructions,cache-references,cache-misses \
      time ollama run "$model" "$neutral_prompt"

    # Stop GPU logging
    kill $GPU_PID
    wait $GPU_PID 2>/dev/null || true

    # Output GPU metrics summary
    echo "=== GPU metrics summary for exam ($model) ==="
    awk -F, '{gpu+=$3; mem+=$5; count++} END {printf "Average GPU: %.1f%%, Average memory used: %.1f MiB\n", gpu/count, mem/count}' "$TMP_GPU"
    rm -f "$TMP_GPU"

    echo "================================================="
done
