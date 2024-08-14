#!/usr/bin/env bash

# Set defaults
if [[ -z "$ARCH" ]]; then
	ARCH="$(
		if [[ "$(arch)" = 'arm64' ]]; then
			echo 'aarch64'
		else
			echo "$(arch)"
		fi
	)"
fi
if [[ -z "$OS" ]]; then
	OS="$(uname | tr '[:upper:]' '[:lower:]')"
fi
if [[ -z "$OWNER" ]]; then
	OWNER="$(
		if (which fbclone >/dev/null); then
			echo "work"
		else
			echo "me"
		fi
	)"
fi

SYSTEM="${ARCH}-${OS}"
CONFIGURATION="${ARCH}-${OS}--${OWNER}"

echo "# Bootstrapping instructions for"
echo "#  operating system: ${OS}"
echo "#  architecture: ${ARCH}"
echo "#  owner: ${OWNER}"
echo ""
echo ""

echo "# Bootstrap nix with the determinate nix installer"
echo "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
echo "# (end bootstrap nix)"
echo ""

if [[ $OS == 'darwin' ]]; then

	echo "# Bootstrap homebrew for nix-darwin to use with casks"
	echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
	echo "# (end bootstrap homebrew)"
	echo ""

	echo "# Build and run darwin-rebuild (nix-darwin)"
	echo "pushd $(pwd)/nix-darwin"
	echo "  nix run . -- --flake '.#${SYSTEM}--${OWNER}' switch"
	echo "popd"
	echo "# (end darwin-rebuild)"
	echo ""

fi

echo "# Build and run home manager on all systems"
echo "pushd $(pwd)/home-manager"
echo "  nix run . -- --flake '.#${SYSTEM}' switch"
echo "popd"
echo "# (end home-manager)"
echo ""
