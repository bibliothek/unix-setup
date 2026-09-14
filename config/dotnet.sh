#!/bin/bash

# dotnet-install.sh puts the SDK in $HOME/.dotnet without touching PATH, so it
# is not visible to this run until a new shell picks it up.
DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
if ! command -v dotnet &> /dev/null && [ -x "$DOTNET_ROOT/dotnet" ]; then
  PATH="$DOTNET_ROOT:$PATH"
fi

# The SDK is optional, so only do anything when it was actually installed.
if ! command -v dotnet &> /dev/null; then
  echo "Skipping dotnet tools: no dotnet on PATH."
  exit 0
fi

echo "Configuring dotnet global tools..."

TOOL="Microsoft.Artifacts.CredentialProvider.NuGet.Tool"

# "dotnet tool install" errors out when the tool is already there, and the tool
# list prints package ids lower-cased.
if dotnet tool list --global | grep -qi "$TOOL"; then
  echo "$TOOL is already installed."
else
  dotnet tool install --global "$TOOL"
fi

# Global tools land in ~/.dotnet/tools, which is not on PATH by default.
case ":$PATH:" in
  *":$HOME/.dotnet/tools:"*) ;;
  *) echo "Note: add \$HOME/.dotnet/tools to PATH to run the tool." ;;
esac
