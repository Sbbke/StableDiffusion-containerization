#!/usr/bin/env bash
#
# Clones custom nodes listed in custom_nodes.txt into $NODE_DIR, using a
# persistent bare-repo cache at $CACHE_DIR (mounted via BuildKit
# --mount=type=cache in Dockerfile.nodes).
#
# Each node is pinned to a ref (tag/branch/commit) from the manifest, so
# rebuilds are reproducible: a given custom_nodes.txt always produces the
# same checked-out code, regardless of what's changed upstream since.
#
# A failure on one node is logged and skipped by default rather than
# aborting the whole build - set STRICT=1 to fail fast instead.

set -uo pipefail

CACHE_DIR="/cache/comfyui-custom-nodes"
NODE_DIR="/stable-diffusion-comfyui/custom_nodes"
MANIFEST="${1:-/manifest/custom_nodes.txt}"
STRICT="${STRICT:-0}"

mkdir -p "$CACHE_DIR" "$NODE_DIR"

failures=()

clone_node() {
    local repo="$1"
    local name="$2"
    local ref="$3"

    local cache_repo="$CACHE_DIR/${name}.git"
    local target="$NODE_DIR/${name}"

    echo "========================================"
    echo "Installing: ${name} @ ${ref}"
    echo "Repository: ${repo}"
    echo "========================================"

    # -----------------------------------------------------
    # Maintain a bare repository cache
    # -----------------------------------------------------
    if [ ! -d "$cache_repo" ]; then
        git clone --mirror "$repo" "$cache_repo" || return 1
    else
        git -C "$cache_repo" remote update || return 1
    fi

    # -----------------------------------------------------
    # Clone working tree from cached repository, pinned to ref
    # ref="HEAD" means: leave it on the default branch (unpinned,
    # matches "always take whatever's newest" behavior).
    # -----------------------------------------------------
    rm -rf "$target"
    git clone --recurse-submodules "$cache_repo" "$target" || return 1
    if [ "$ref" != "HEAD" ] && [ -n "$ref" ]; then
        git -C "$target" checkout "$ref" || return 1
    fi
    git -C "$target" submodule update --init --recursive || true

    # -----------------------------------------------------
    # Install requirements
    # -----------------------------------------------------
    if [ -f "$target/requirements.txt" ]; then
        uv pip install -r "$target/requirements.txt" || return 1
    fi
}

while IFS='|' read -r repo name ref || [ -n "$repo" ]; do
    # skip blank lines and comments
    repo="$(echo "$repo" | xargs)"
    [ -z "$repo" ] && continue
    case "$repo" in \#*) continue ;; esac

    name="$(echo "$name" | xargs)"
    ref="$(echo "$ref" | xargs)"

    if clone_node "$repo" "$name" "$ref"; then
        echo ">>> ${name} OK"
    else
        echo ">>> ${name} FAILED (repo=${repo}, ref=${ref})" >&2
        failures+=("$name")
        if [ "$STRICT" = "1" ]; then
            echo "STRICT=1 set, aborting on first failure." >&2
            exit 1
        fi
    fi
done < "$MANIFEST"

if [ "${#failures[@]}" -gt 0 ]; then
    echo "----------------------------------------"
    echo "Completed with failures: ${failures[*]}"
    echo "(set STRICT=1 to fail the build on any node error)"
    echo "----------------------------------------"
fi

exit 0
