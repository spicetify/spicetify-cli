#!/bin/sh
# Copyright 2019 khanhas. GPL license.
# Edited from project Denoland install script (https://github.com/denoland/deno_install)

set -e

case $(uname -sm) in
    "Darwin x86_64") target="darwin-amd64" ;;
    "Darwin arm64") target="darwin-arm64" ;;
    "Linux x86_64") target="linux-amd64" ;;
    *) echo "Unsupported platform $(uname -sm). Only Darwin x86_64, Darwin arm64 and Linux x86_64 binaries are available."
    exit ;;
esac

if [ $# -eq 0 ]; then
    latest_release_uri="https://api.github.com/repos/khanhas/spicetify-cli/releases/latest"
    echo "DOWNLOADING    $latest_release_uri"
	spicetify_asset_path=$(
		command curl -sSf "$latest_release_uri" |
			command grep -o "/khanhas/spicetify-cli/releases/download/.*/spicetify-.*-${target}\\.tar\\.gz" |
			command head -n 1
	)
	if [ ! "$spicetify_asset_path" ]; then exit 1; fi
	download_uri="https://github.com${spicetify_asset_path}"
else
	download_uri="https://github.com/khanhas/spicetify-cli/releases/download/v${1}/spicetify-${1}-${target}.tar.gz"
fi

spicetify_install="$HOME/spicetify-cli"

if [[ "$target" == *"darwin"* ]]; then
	if [ ! -d "$HOME/.config" ]; then
  	echo "Creating .config folder inside $HOME";
		mkdir -p "$HOME/.config"
	fi

	spicetify_install="$HOME/.spicetify"
	rcFile="$HOME/.zshenv"
	if ! grep -q "$spicetify_install" "$rcFile"; then
		echo "export PATH=${spicetify_install}:$PATH" >> "$rcFile"
	fi
fi

exe="$spicetify_install/spicetify"

if [ ! -d "$spicetify_install" ]; then
  echo "Creating $spicetify_install";
	mkdir -p "$spicetify_install"
fi

tar_file="$exe.tar.gz"

echo "DOWNLOADING    $download_uri"
curl --fail --location --progress-bar --output "$tar_file" "$download_uri"
cd "$spicetify_install"

echo "EXTRACTING     $tar_file"
tar xzf "$tar_file"

chmod +x "$exe"

echo "REMOVING       $tar_file"
rm "$tar_file"

echo ""
echo "spicetify was installed successfully to $exe"
echo ""
if command -v spicetify > /dev/null; then
	echo "Run 'spicetify --help' to get started"
elif [[ "$spicetify_install" == *".config"* ]]; then
	echo "Please restart your Terminal to have spicetify in your PATH."
	echo "Then you can run:"
	echo "'$exe --help' to get started"
else
	echo "Manually add the directory to your \$HOME/.bash_profile (or similar)"
	echo "  export SPICETIFY_INSTALL=\"$spicetify_install\""
	echo "  export PATH=\"\$SPICETIFY_INSTALL:\$PATH\""
    echo ""
	echo "Run '$exe --help' to get started"
fi