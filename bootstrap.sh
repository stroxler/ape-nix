#!/usr/bin/env bash

# Bootstrap nix with the determinate nix installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Bootstrap homebrew (I'm trying to use nix for most projects, but
# brew cask remains my preferred way to handle apps for now, using nix
# for that is tricky plus nix doesn't have everything).
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# Determine the current system name
ARCH="$(
  if [[ "$(arch)" = 'arm64' ]];
  then echo 'aarch64';
  else echo "$(arch)";
  fi)"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
SYSTEM="${ARCH}-${OS}"

# Build and run home manager
nix build '.#home-manager'
./result/bin/home-manager --flake ".#${SYSTEM}" switch

# Build and run darwin-rebuild (nix-darwin) if on macos
if [[ $OS == 'darwin ]]; then
  nix build '.#darwin-rebuild'
  ./result/bin/darwin-rebuild --flake ".#${SYSTEM}" switch
fi