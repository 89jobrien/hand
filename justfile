# hand — session handoff plugin

# Set up local git hooks and install the plugin. Run once after cloning.
init:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "==> hand: plugin init"

    # 1. Wire local hooks
    git config core.hooksPath .githooks
    chmod +x .githooks/pre-commit .githooks/post-commit
    echo "    hooks: .githooks wired"

    # 2. Verify claude is available
    if ! command -v claude >/dev/null 2>&1; then
        echo "    ERROR: 'claude' not on PATH — install Claude Code first"
        echo "    https://claude.ai/code"
        exit 1
    fi

    # 3. Register local marketplace if not already registered
    MARKETPLACE="$HOME/.claude/plugins/local-marketplace"
    if [ -d "$MARKETPLACE" ]; then
        claude plugin marketplace add "$MARKETPLACE" 2>/dev/null || true
        echo "    marketplace: local registered"
    else
        echo "    WARNING: local marketplace not found at $MARKETPLACE"
        echo "    Plugin will be installed directly from this directory."
    fi

    # 4. Install / reinstall plugin
    claude plugin uninstall hand --force 2>/dev/null || true
    claude plugin install hand@local
    echo "    plugin: hand installed"

    echo ""
    echo "==> Done. Restart Claude Code to apply."

# Reinstall plugin without re-running full init
reinstall:
    #!/usr/bin/env bash
    claude plugin uninstall hand --force 2>/dev/null || true
    claude plugin install hand@local
    echo "[hand] reinstalled — restart Claude Code to apply"
