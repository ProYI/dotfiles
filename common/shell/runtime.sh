# Runtime tool environment initialization
# Each block is guarded -- only runs if the tool exists on this system.

# --- Python: user-local scripts on PATH ---
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- Node: fnm (Fast Node Manager) ---
if [ -d "$HOME/.local/share/fnm" ]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
fi
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# --- Rust: cargo/rustup ---
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# --- Java: sdkman ---
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# --- Docker: BuildKit + Compose v2 ---
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1