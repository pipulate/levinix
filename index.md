                                                      .--.      ___________
      _               _       _         ,--./,-.     |o_o |    |     |     |
     | |    _____   _(_)_ __ (_)_  __  / #      \    |:_/ |    |     |     |
     | |   / _ \ \ / / | '_ \| \ \/ / |          |  //   \ \   |_____|_____|
     | |__|  __/\ V /| | | | | |>  <   \        /  (|     | )  |     |     |
     |_____\___| \_/ |_|_| |_|_/_/\_\   `._,._,'  /'\_   _/`\  |     |     |
                                                  \___)=(___/  |_____|_____|

# Levinix: A *very good* "No Problem" Universal Packager (NPvg)

Write once run anywhere (WORA), solving the "It works on my machine" problem without the cloud.

**Levinix** is the successor to Darwinix. It is a completely self-contained, auto-updating, cross-platform development environment powered by Nix Flakes. It represents a paradigm shift away from fragile Docker containers and OS-specific setup scripts. 

It is **Infrastructure as Code**, designed as an alternative to the Electron app model and solve the "Works on My Machine" problem forever.

## The Dream of "Write Once, Run Anywhere" Achieved

Most modern development is done on Linux, but Macs are Unix. If you think Homebrew and Docker are the solution, you're wrong. Welcome to the world of **Nix Flakes**! 

Levinix defines a reproducible development environment that works across Linux, macOS, and Windows (via WSL2). It is like a recipe for your perfect workspace, ensuring everyone on your team has the exact same setup, every time, down to the exact C-library version. 

## Key Features

1. **The "Magic Cookie" Installer**: Zero prerequisites. You don't even need `git` installed to bootstrap Levinix. 
2. **Sovereign Workspace**: Transforms a raw directory into a fully functional, isolated Git repository automatically on first run.
3. **Auto-Updating Engine**: Seamlessly checks for remote updates and pulls them safely without destroying your local work.
4. **The Triple-Quote Compromise**: Uses Nix for the immutable bedrock (Python binaries, C-libraries) but provides a standard, writable `.venv` for `pip` flexibility.
5. **Cross-Platform**: Normalizes dependencies across macOS, Linux, and WSL natively.

## How to Use Levinix (The One-Liner)

We have engineered a frictionless deployment pipeline. You do not need to clone this repository manually. 

To deploy a new, sovereign Levinix environment (we will call it `MyKillerApp`), simply run this command in your terminal:

```bash
curl -L [https://levinix.com/install.sh](https://levinix.com/install.sh) | bash -s MyKillerApp
```

### What happens when you run this?

1. **The Universe Builder:** The script checks if you have the Nix package manager installed. If not, it safely installs it via the Determinate Systems installer.
2. **The Magic Cookie Fetch:** It downloads the core Levinix DNA directly from GitHub, without requiring `git` to be installed on the host machine.
3. **The Staging:** It extracts the environment into `~/MyKillerApp` and stages the `.app_identity`.

### Launching the Environment

Once the installer finishes, simply navigate into your new app directory and pull the trigger:

```bash
cd ~/MyKillerApp
./run
```

**The Genesis Event:** On the very first run, Levinix will detect that it is not yet a git repository. It will silently initialize Git, seal the environment with a Genesis commit, and build your Python `.venv` atop the immutable Nix bedrock.

You will be greeted with the Levinix visual anchor in your terminal prompt:
`(levinix) [user@host:~/MyKillerApp]$`

## Understanding the Architecture

You can view the complete Nix flake configuration at [https://github.com/pipulate/levinix/blob/main/flake.nix](https://www.google.com/search?q=https://github.com/pipulate/levinix/blob/main/flake.nix).

Here's a brief guide to understanding its structure:

* **`corePackages`**: The immutable bedrock. This defines the exact versions of Python 3.12, SQLite, Git, and underlying C-libraries that are guaranteed to be identical across every operating system.
* **`magicCookieLogic`**: The shell hook that handles the Genesis git initialization and the non-destructive auto-update sequence on subsequent runs.
* **`pythonSetupLogic`**: The bridge between the immutable Nix store and the dynamic reality of Python development. It synthesizes the `.venv` locally, allowing standard `pip install` workflows to operate smoothly.

## Development Flexibility

This Nix flake is not intended to be a restrictive cage; rather, it serves as a foundational starting point. It includes all the necessary C-related dependencies for building pip packages that may not have pre-built wheels and can still be compiled from source.

### A Time-Tested Approach

If you think this is a recent innovation, think again. Nix, the foundation of this approach, has been quietly revolutionizing system configuration and package management for over two decades. Born in 2003 as a research project at Utrecht University, Nix introduced a purely functional approach to package management, ensuring reproducibility and consistency.

This ecosystem has been solving the "works on my machine" problem long before containers became mainstream. With its declarative configuration, atomic updates, and isolation of packages, Nix provides a robust alternative to traditional system management methods. By utilizing Levinix, you are standing on the shoulders of giants.
