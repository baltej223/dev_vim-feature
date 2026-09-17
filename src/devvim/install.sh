#!/bin/bash

set -e

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y curl ca-certificates tar
        rm -rf /var/lib/apt/lists/*

    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache curl ca-certificates tar

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl ca-certificates tar

    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl ca-certificates tar

    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

install_dependencies

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        NVIM_ARCH="x86_64"
        ;;

    aarch64|arm64)
        NVIM_ARCH="arm64"
        ;;

    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"

TMP_DIR="$(mktemp -d)"

curl -fsSL "$URL" \
    -o "$TMP_DIR/nvim.tar.gz"

rm -rf /opt/nvim

mkdir -p /opt/nvim

tar \
    -xzf "$TMP_DIR/nvim.tar.gz" \
    --strip-components=1 \
    -C /opt/nvim

ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

rm -rf "$TMP_DIR"

echo "DevVim installed:"
nvim --version | head -n 1
