{
  description = "Levinix: The Electron-Killer WORA Wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        isLinux = pkgs.stdenv.isLinux;
        # The Bedrock Dependencies (Normalized across macOS/Linux/WSL — Pure pip edition)
        corePackages = (with pkgs; [
          git curl wget sqlite tmux figlet zlib cmake htop
          (python312.withPackages (ps: with ps; [ pip virtualenv ]))
        ]) ++ (with pkgs; pkgs.lib.optionals isLinux [
          gcc
          stdenv.cc.cc.lib
        ]);

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
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath corePackages}:$LD_LIBRARY_PATH
        '';
        runScript = pkgs.writeShellScriptBin "run-script" ''
          #!/usr/bin/env bash
          source .venv/bin/activate
          if [ -f requirements.txt ]; then
            echo "- Installing pip packages..."
            if pip install --upgrade pip --quiet && pip install -r requirements.txt --quiet; then
              package_count=$(pip list --format=freeze | wc -l)
              echo "- Done. $package_count pip packages installed."
            else
              echo "Warning: An error occurred during pip setup."
            fi
          fi
          if python -c "import numpy" 2>/dev/null; then
            echo "- numpy is importable (good to go!)"
            echo "To start JupyterLab, type: start"
            echo "To stop JupyterLab, type: stop"
          fi
          cat << 'EOF' > .venv/bin/start
          #!/bin/sh
          echo "A JupyterLab tab will open in your default browser."
          tmux kill-session -t jupyter 2>/dev/null || true
          tmux new-session -d -s jupyter 'source .venv/bin/activate && jupyter lab --NotebookApp.token="" --NotebookApp.password="" --NotebookApp.disable_check_xsrf=True'
          echo "If no tab opens, visit http://localhost:8888"
          echo "To view JupyterLab server: tmux attach -t jupyter"
          echo "To stop JupyterLab server: stop"
          EOF
          chmod +x .venv/bin/start
          cat << 'EOF' > .venv/bin/stop
          #!/bin/sh
          echo "Stopping tmux session 'jupyter'..."
          tmux kill-session -t jupyter 2>/dev/null || true
          echo "The tmux session 'jupyter' has been stopped."
          EOF
          chmod +x .venv/bin/stop
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
            ${runScript}/bin/run-script

            ${pkgs.lib.optionalString isLinux ''
            if command -v nvidia-smi &> /dev/null; then
              export CUDA_HOME=${pkgs.cudatoolkit}
              export PATH=$CUDA_HOME/bin:$PATH
              export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
            fi
            ''}
            nix() {
              LD_LIBRARY_PATH="" command nix "$@"
            }
            # --- ADDED: Visual Environment Anchor ---
            export PS1="(levinix) $PS1"
          '';
        };
        devShells.quiet = pkgs.mkShell {
          buildInputs = corePackages;
          shellHook = ''
            ${pythonSetupLogic}
            ${pkgs.lib.optionalString isLinux ''
            if command -v nvidia-smi &> /dev/null; then
              export CUDA_HOME=${pkgs.cudatoolkit}
              export PATH=$CUDA_HOME/bin:$PATH
              export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
            fi
            ''}
            nix() {
              LD_LIBRARY_PATH="" command nix "$@"
            }
            echo "Quiet Nix environment activated."
          '';
        };
      });
}
