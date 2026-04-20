{
  description = "ZMK Firmware Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Core dependencies
            git
            gh  # GitHub CLI for authentication

            # UV package manager (for installing zmk-cli)
            uv

            # Python (UV might need it)
            python3

            # Additional tools that might be helpful
            curl
            wget
            jq
          ];

          shellHook = ''
            echo "🔧 ZMK Development Environment"
            echo "==============================================="
            echo "Available tools:"
            echo "  - git: $(git --version)"
            echo "  - gh: $(gh --version 2>/dev/null || echo "not authenticated")"
            echo "  - uv: $(uv --version)"
            echo ""

            # Set up UV tool directory
            export UV_TOOL_DIR="$PWD/.uv-tools"
            mkdir -p "$UV_TOOL_DIR/bin"
            export PATH="$UV_TOOL_DIR/bin:$PATH"

            # Check if zmk is already available in our local bin
            if [[ -f "$UV_TOOL_DIR/bin/zmk" ]]; then
              echo "✅ ZMK CLI already available: $(zmk --version)"
            else
              echo "📦 Installing ZMK CLI..."
              # Install zmk (force to handle existing installations)
              uv tool install zmk --force 2>/dev/null || true

              # Create symlink to make it appear local to the project
              if [[ -f "$HOME/.local/bin/zmk" ]]; then
                ln -sf "$HOME/.local/bin/zmk" "$UV_TOOL_DIR/bin/zmk"
                echo "✅ ZMK CLI installed and linked: $(zmk --version)"
              else
                echo "❌ Failed to install ZMK CLI"
              fi
            fi

            echo ""
            echo "Next steps:"
            echo "  1. Authenticate with GitHub: gh auth login"
            echo "  2. Initialize ZMK repo: zmk init"
            echo "  3. Add your keyboard: zmk keyboard add"
            echo ""
          '';

        };
      });
}