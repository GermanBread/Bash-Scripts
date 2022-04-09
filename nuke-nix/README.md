# nuke Nix

This script (partially) removes the Nix package manager from your system

## Prerequisites

- you installed the Nix package manager using `sh <(curl -L https://nixos.org/nix/install) --daemon`

## Caveats

- You need to clean some files in /etc after the removal. Those files are not handled automatically (yet)