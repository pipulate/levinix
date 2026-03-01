{
  description = "Levinix: The Electron-Killer WORA Wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # The Bedrock Dependencies (Normalized across macOS/Linux/WSL)
        corePackages = with pkgs; [
          git curl sqlite tmux
          (python312.withPackages (ps: with ps; [ pip virtualenv ]))
        ];

        # The Magic Cookie: Git Transformation & Auto-Update
        magicCookieLogic = ''
          # 1. Safe Initialization
          if [ ! -d .git ]; then
            echo "🔄 Transforming static folder into local Git repository..."
            git init -q
            git branch -m main
            git add .
            git commit -q -m "Genesis: Levinix environment sealed."
            echo "✅ Sovereign workspace established."
          else
            # 2. Robust Auto-Update (Only if remote exists)
            if git remote -v | grep -q "origin"; then
               echo "Checking for updates..."
               git fetch origin -q || true # Don't fail if offline
               
               LOCAL=$(git rev-parse HEAD)
               # Only try to parse upstream if it actually exists
               REMOTE=$(git ls-remote --heads origin main 2>/dev/null | awk '{print $1}')
               
               if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then 
                   echo "✨ An update is available on the remote branch."
                   echo "   Run 'git pull origin main' when you are ready to update." 
               fi
            fi
          fi
        '';

        # The Triple-Quote Compromise: A writable Python sandbox atop immutable Nix
        pythonSetupLogic = ''
          if [ ! -d .venv ]; then
            echo "🧪 Synthesizing local Python environment..."
            ${pkgs.python312}/bin/python -m venv .venv
          fi
          export VIRTUAL_ENV="$(pwd)/.venv"
          export PATH="$VIRTUAL_ENV/bin:$PATH"
        '';

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = corePackages;
          shellHook = ''
            ${magicCookieLogic}
            ${pythonSetupLogic}
            
            APP="Levinix"
            if [ -f .app_identity ]; then APP=$(cat .app_identity); fi
            
            echo "=========================================================="
            echo "  🚀 $APP is Online"
            echo "=========================================================="
            echo " The 'No Problem' stack is very good."
            echo " Type 'python server.py' (or your app's entry point) to begin."

            # --- ADDED: Visual Environment Anchor ---
            export PS1="(levinix) $PS1"
          '';
        };
      });
}
