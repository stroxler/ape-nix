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
	echo "pushd $(pwd)/nix-darwin"
	echo "  sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin"
	echo "  nix run . -- --flake '.#${SYSTEM}--${OWNER}' switch"
	echo "popd"
	echo "# (end darwin-rebuild)"
	echo ""

else

	echo "# Bootstrap single-user nix + flakes with the vanilla nix installer"
	echo "curl -L https://nixos.org/nix/install >  ~/_bootstrap_standard_nix.sh"
	echo "bash ~/_bootstrap_standard_nix --no-deamon --yes"
	echo "mkdir -p ~/.config/nix/nix.conf"
	echo "echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
	echo ""

	echo "# Back up the default dotfiles"
	echo "mv ~/.profile ~/.profile.pre-hm || true"
	echo "mv ~/.bash_profile ~/.bash_profile.pre-hm || true"
	echo "mv ~/.bashrc ~/.bashrc.pre-hm || true"
	echo "mv ~/.config/fish/config.fish ~/.config/fish/config.fish.pre-hm || true"
	echo "mv ~/.zshrc ~/.zshrc.pre-hm || true"
fi

echo "# Build and run home manager on all systems"
echo "pushd $(pwd)/home-manager"
echo "  nix run . -- --flake '.#${SYSTEM}' switch"
echo "popd"
echo "# (end home-manager)"
echo ""
