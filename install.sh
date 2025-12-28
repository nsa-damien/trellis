#!/usr/bin/env bash
#
# Trellis installer
# Installs Claude Code commands for spec-kit + beads integration
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install Trellis commands for Claude Code.

Options:
    --user          Install to user-level (~/.claude/commands/)
    --project       Install to current project (.claude/commands/)
    --project-dir   Install to specified project directory
    --uninstall     Remove installed commands
    --help          Show this help message

Examples:
    $0 --user                           # Install for all projects
    $0 --project                        # Install for current project
    $0 --project-dir /path/to/project   # Install for specific project
    $0 --uninstall --user               # Remove user-level installation
EOF
}

install_commands() {
    local dest_dir="$1"

    # Create destination directory if needed
    mkdir -p "$dest_dir"

    # Create symlinks to command files
    for cmd in "$COMMANDS_DIR"/*.md; do
        if [[ -f "$cmd" ]]; then
            local basename="$(basename "$cmd")"
            local target="$dest_dir/$basename"

            # Remove existing file/symlink if present
            if [[ -e "$target" ]] || [[ -L "$target" ]]; then
                rm "$target"
            fi

            ln -s "$cmd" "$target"
            print_status "Linked $(basename "$cmd") -> $cmd"
        fi
    done

    echo ""
    print_status "Commands installed to: $dest_dir"
    echo ""
    echo "Available commands:"
    echo "  /trellis.import      - Import tasks.md to beads"
    echo "  /trellis.implement   - Execute with beads tracking"
    echo "  /trellis.sync        - Sync beads ↔ tasks.md"
    echo "  /trellis.ready       - Show available work"
    echo "  /trellis.status      - Project health overview"
}

uninstall_commands() {
    local dest_dir="$1"
    local removed=0

    for cmd in trellis.import.md trellis.implement.md trellis.sync.md trellis.ready.md trellis.status.md; do
        if [[ -f "$dest_dir/$cmd" ]]; then
            rm "$dest_dir/$cmd"
            print_status "Removed $cmd"
            ((removed++))
        fi
    done

    # Also remove old speckit.beads-* commands if present
    for cmd in speckit.beads.md speckit.beads-implement.md speckit.beads-sync.md; do
        if [[ -f "$dest_dir/$cmd" ]]; then
            rm "$dest_dir/$cmd"
            print_status "Removed legacy $cmd"
            ((removed++))
        fi
    done

    if [[ $removed -eq 0 ]]; then
        print_warning "No Trellis commands found in $dest_dir"
    else
        print_status "Uninstalled $removed commands from $dest_dir"
    fi
}

# Parse arguments
INSTALL_TYPE=""
PROJECT_DIR=""
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            INSTALL_TYPE="user"
            shift
            ;;
        --project)
            INSTALL_TYPE="project"
            PROJECT_DIR="$(pwd)"
            shift
            ;;
        --project-dir)
            INSTALL_TYPE="project"
            PROJECT_DIR="$2"
            shift 2
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate arguments
if [[ -z "$INSTALL_TYPE" ]]; then
    print_error "Please specify --user or --project"
    echo ""
    usage
    exit 1
fi

# Determine destination directory
if [[ "$INSTALL_TYPE" == "user" ]]; then
    DEST_DIR="$HOME/.claude/commands"
else
    DEST_DIR="$PROJECT_DIR/.claude/commands"
fi

# Check that commands directory exists in source
if [[ ! -d "$COMMANDS_DIR" ]]; then
    print_error "Commands directory not found: $COMMANDS_DIR"
    exit 1
fi

# Execute install or uninstall
if [[ "$UNINSTALL" == true ]]; then
    uninstall_commands "$DEST_DIR"
else
    install_commands "$DEST_DIR"
fi

echo ""
print_status "Done!"
