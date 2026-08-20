#!/bin/bash
set -euo pipefail

# ============================================================================
# Sync ALOE install scripts → aloe public dir
# ============================================================================
# aloe serves the installer at https://aloe.ai/ALOE-update, which
# is a Next.js rewrite to the STATIC file public/aloe-install.sh baked
# into the Cloud Run image at build time. That file is a mirror of THIS repo's
# scripts/update.sh — the source of truth. They drift whenever update.sh changes
# and nobody copies it across (this caused a stale installer in 06/2026).
#
# Run this after any change to scripts/update.sh / scripts/update.ps1, then
# commit + deploy aloe. The aloe CI guard (aloe-install-sync)
# fails the build if the mirror is stale.
#
# Usage:
#   scripts/sync-install-to-aloe.sh           # copy + verify
#   scripts/sync-install-to-aloe.sh --check    # verify only (non-zero on drift)
#   BLOCKRUN_DIR=/path/to/aloe scripts/sync-install-to-aloe.sh
# ============================================================================

ALOE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLOCKRUN_DIR="${BLOCKRUN_DIR:-$(cd "$ALOE_DIR/../aloe" 2>/dev/null && pwd || true)}"

CHECK_ONLY=false
[ "${1:-}" = "--check" ] && CHECK_ONLY=true

if [ -z "$BLOCKRUN_DIR" ] || [ ! -d "$BLOCKRUN_DIR/public" ]; then
  echo "✗ aloe public dir not found (looked for \$BLOCKRUN_DIR/public)."
  echo "  Set BLOCKRUN_DIR=/path/to/aloe and re-run."
  exit 1
fi

# source-of-truth → served mirror
declare -a PAIRS=(
  "scripts/update.sh:public/aloe-install.sh"
  "scripts/update.ps1:public/aloe-install.ps1"
)

drift=0
for pair in "${PAIRS[@]}"; do
  src="$ALOE_DIR/${pair%%:*}"
  dst="$BLOCKRUN_DIR/${pair##*:}"
  name="$(basename "$dst")"

  if [ ! -f "$src" ]; then
    echo "✗ missing source: $src"
    exit 1
  fi

  if cmp -s "$src" "$dst"; then
    echo "✓ $name already in sync"
    continue
  fi

  drift=1
  if [ "$CHECK_ONLY" = true ]; then
    echo "✗ $name is STALE (differs from $(basename "$src"))"
  else
    cp "$src" "$dst"
    echo "✓ $name synced ($(wc -l <"$dst" | tr -d ' ') lines)"
  fi
done

if [ "$CHECK_ONLY" = true ] && [ "$drift" -ne 0 ]; then
  echo ""
  echo "Run: scripts/sync-install-to-aloe.sh   (then commit + deploy aloe)"
  exit 1
fi

if [ "$CHECK_ONLY" = false ] && [ "$drift" -ne 0 ]; then
  echo ""
  echo "→ Now commit the change in aloe and deploy (./deploy-safe.sh) so"
  echo "  https://aloe.ai/ALOE-update serves the updated script."
fi
