#!/usr/bin/env bash
#
# Symlink every dotfile in this repo into $HOME, preserving the same
# relative directory structure. Safe to re-run: existing correct symlinks
# are left alone, and anything else in the way is backed up first.
#
# Usage: ./install.sh [-n|--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Files/dirs in this repo that should NOT be symlinked into $HOME.
EXCLUDES=(
    ".git"
    ".gitignore"
    ".DS_Store"
    "README.md"
    "CHANGELOG.md"
    "LICENSE"
    "install.sh"
    "hooks"
)

if [[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ -d "$DOTFILES_DIR/.git" ]] && [[ "$(git -C "$DOTFILES_DIR" config --get core.hooksPath || true)" != "hooks" ]]; then
    echo "hooks   core.hooksPath -> hooks"
    $DRY_RUN || git -C "$DOTFILES_DIR" config core.hooksPath hooks
fi

is_excluded() {
    local rel="$1"
    local top="${rel%%/*}"
    local ex
    for ex in "${EXCLUDES[@]}"; do
        [[ "$rel" == "$ex" || "$top" == "$ex" ]] && return 0
    done
    return 1
}

link_file() {
    local src="$1" dest="$2"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "ok      $dest"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "backup  $dest -> $BACKUP_DIR/${dest#$HOME/}"
        if ! $DRY_RUN; then
            mkdir -p "$(dirname "$BACKUP_DIR/${dest#$HOME/}")"
            mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
        fi
    fi

    echo "link    $dest -> $src"
    if ! $DRY_RUN; then
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
    fi
}

while IFS= read -r -d '' file; do
    rel="${file#"$DOTFILES_DIR"/}"
    is_excluded "$rel" && continue
    link_file "$file" "$HOME/$rel"
done < <(find "$DOTFILES_DIR" -type f -print0)

$DRY_RUN && echo "(dry run, nothing changed)"
