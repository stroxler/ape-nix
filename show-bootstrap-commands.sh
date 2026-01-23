#!/usr/bin/env bash

THIS_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

if [[ $OS == 'darwin' ]]; then

	echo "# Bootstrap nix with the determinate nix installer"
	echo "#   (Note: I'm not 100% sure the id overrides will work in macos, they are needed for work machines)"
	echo "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix ~/_bootstrap_determinate_nix.sh"
	echo "bash ~/_bootstrap_determinate_nix.sh install --no-confirm"
	echo " # (end bootstrap nix)"
	echo ""

	echo "# Bootstrap homebrew for nix-darwin to use with casks"
	echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
	echo "# (end bootstrap homebrew)"
	echo ""

	echo "# Build and run darwin-rebuild (nix-darwin)"
	echo "pushd ${THIS_SCRIPT_DIR}/nix-darwin"
	echo "  sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin"
	echo "  nix run . -- --flake '.#${SYSTEM}--${OWNER}' switch"
	echo "popd"
	echo "# (end darwin-rebuild)"
	echo ""

else

	echo "# Bootstrap single-user nix + flakes with the vanilla nix installer"
	echo "curl -L https://nixos.org/nix/install >  ~/_bootstrap_standard_nix.sh"
	echo "bash ~/_bootstrap_standard_nix.sh --yes"
	echo "mkdir -p ~/.config/nix/nix.conf"
	echo "echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
  echo ". ~/.nix-profile/etc/profile.d/nix.sh"
	echo ""

fi
echo "# Back up the default dotfiles"
echo "mv ~/.profile ~/.profile.pre-hm 2> /dev/null || true"
echo "mv ~/.bash_profile ~/.bash_profile.pre-hm 2> /dev/null || true"
echo "mv ~/.bashrc ~/.bashrc.pre-hm 2> /dev/null || true"
echo "mv ~/.config/fish/config.fish ~/.config/fish/config.fish.pre-hm 2> /dev/null || true"
echo "mv ~/.zprofile ~/.zprofile.pre-hm 2> /dev/null || true"
echo "mv ~/.zshrc ~/.zshrc.pre-hm 2> /dev/null || true"
echo ""

echo "# Build and run home manager on all systems"
echo "pushd ${THIS_SCRIPT_DIR}/home-manager"
echo "  nix run . -- --flake '.#${SYSTEM}' switch"
echo "popd"
echo "# (end home-manager)"
echo ""
