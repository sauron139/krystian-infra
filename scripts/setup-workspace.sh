#!/usr/bin/env bash
# Sets up the workspace folder around the four repos:
#   ../CLAUDE.md -> krystian-infra/WORKSPACE.md
#   ../docs      -> krystian-infra/docs
# and warns about any sibling repo that isn't cloned yet.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE="$(dirname "$INFRA_DIR")"
INFRA_NAME="$(basename "$INFRA_DIR")"

link() { # link <target relative to workspace> <link name>
  local target="$1" name="$WORKSPACE/$2"
  if [ -L "$name" ] || [ ! -e "$name" ]; then
    ln -sfn "$target" "$name"
  else
    echo "skip: $name exists and is not a symlink"
  fi
}
link "$INFRA_NAME/WORKSPACE.md" CLAUDE.md
link "$INFRA_NAME/docs" docs

missing=0
for repo in krystian-backend krystian-frontend krystian-admin; do
  if [ ! -d "$WORKSPACE/$repo" ]; then
    echo "missing: $WORKSPACE/$repo (clone it next to $INFRA_NAME)"
    missing=1
  fi
done
exit $missing
