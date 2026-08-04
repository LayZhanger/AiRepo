#!/bin/bash
# AgentRepo — 仓库管理器
# Usage:
#   ./repo.sh clone          Clone/pull all repos from repos.txt
#   ./repo.sh pull           Git pull all repos
#   ./repo.sh add <name> <url>  Add a new repo to repos.txt
#   ./repo.sh list           List all repos
#   ./repo.sh status         Git status of all repos

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOS_FILE="$SCRIPT_DIR/repos.txt"

usage() {
    echo "Usage: $0 <command>"
    echo "  clone          Clone/pull all repos from repos.txt"
    echo "  pull           Git pull all repos"
    echo "  add <n> <u>    Add a new repo (name url) to repos.txt"
    echo "  list           List all repos"
    echo "  status         Git status of all repos"
    exit 1
}

[ $# -ge 1 ] || usage
CMD="$1"
shift

case "$CMD" in
    clone)
        if [ ! -f "$REPOS_FILE" ]; then
            echo "ERROR: $REPOS_FILE not found"
            exit 1
        fi
        while IFS=' ' read -r name url; do
            [ -z "$name" ] && continue
            target="$SCRIPT_DIR/../$name"
            if [ -d "$target/.git" ]; then
                echo "  [pull] $name"
                git -C "$target" pull
            else
                echo "  [clone] $name <- $url"
                git clone "$url" "$target"
            fi
        done < "$REPOS_FILE"
        ;;

    pull)
        if [ ! -f "$REPOS_FILE" ]; then
            echo "ERROR: $REPOS_FILE not found"
            exit 1
        fi
        while IFS=' ' read -r name url; do
            [ -z "$name" ] && continue
            target="$SCRIPT_DIR/../$name"
            if [ -d "$target/.git" ]; then
                echo "  [pull] $name"
                git -C "$target" pull
            fi
        done < "$REPOS_FILE"
        ;;

    add)
        [ $# -ge 2 ] || { echo "Usage: $0 add <name> <url>"; exit 1; }
        name="$1"; url="$2"
        echo "$name $url" >> "$REPOS_FILE"
        echo "  [added] $name $url"
        ;;

    list)
        if [ ! -f "$REPOS_FILE" ]; then
            echo "(no repos.txt)"
            exit 0
        fi
        echo "Repositories:"
        while IFS=' ' read -r name url; do
            [ -z "$name" ] && continue
            echo "  $name  <-  $url"
        done < "$REPOS_FILE"
        ;;

    status)
        if [ ! -f "$REPOS_FILE" ]; then
            echo "(no repos.txt)"
            exit 0
        fi
        while IFS=' ' read -r name url; do
            [ -z "$name" ] && continue
            target="$SCRIPT_DIR/../$name"
            if [ -d "$target/.git" ]; then
                echo "=== $name ==="
                git -C "$target" status --short
            else
                echo "=== $name (not cloned) ==="
            fi
        done < "$REPOS_FILE"
        ;;

    *)
        usage
        ;;
esac
