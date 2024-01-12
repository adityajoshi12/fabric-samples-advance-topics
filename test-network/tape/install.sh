#!/bin/bash

RELEASE_TAG="v0.2.6"
GITHUB_REPO="https://github.com/Hyperledger-TWGC/tape/releases/download"

# Check the operating system
OS=$(uname -s)

# Set the appropriate binary file based on the operating system
case "$OS" in
    "Linux")
        BINARY_FILE="tape-Linux-X64"
        ;;
    "Darwin")
        BINARY_FILE="tape-macos-X64"
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Download the binary
DOWNLOAD_URL="$GITHUB_REPO/$RELEASE_TAG/$BINARY_FILE"
curl -LO "$DOWNLOAD_URL"

# Make the binary executable
chmod +x "$BINARY_FILE"

echo "Downloaded $BINARY_FILE from $DOWNLOAD_URL"
