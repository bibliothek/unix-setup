#!/bin/bash

DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"

# dotnet-install.sh drops the SDK in $HOME/.dotnet, which is not on PATH until a
# new shell picks it up, so look there too before deciding anything is missing.
resolve_dotnet() {
  if command -v dotnet &> /dev/null; then
    DOTNET=dotnet
  elif [ -x "$DOTNET_ROOT/dotnet" ]; then
    DOTNET="$DOTNET_ROOT/dotnet"
  else
    DOTNET=""
  fi
}

resolve_dotnet

CHANNELS=(10.0 8.0)
MISSING=()

for CHANNEL in "${CHANNELS[@]}"; do
  # "dotnet --list-sdks" prints a "<version> [<path>]" line per SDK, so match on
  # the major version rather than the channel, which is not a version itself.
  if [ -n "$DOTNET" ] && "$DOTNET" --list-sdks | grep -q "^${CHANNEL%%.*}\."; then
    echo ".NET SDK $CHANNEL is already installed."
  else
    MISSING+=("$CHANNEL")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
  chmod +x dotnet-install.sh

  for CHANNEL in "${MISSING[@]}"; do
    ./dotnet-install.sh --channel "$CHANNEL"
  done

  rm ./dotnet-install.sh

  # The first install is what put dotnet in $DOTNET_ROOT, so look again.
  resolve_dotnet
fi

echo "Installing dotnet global tools..."

TOOL="Microsoft.Artifacts.CredentialProvider.NuGet.Tool"

# "dotnet tool install" errors out when the tool is already there, and the tool
# list prints package ids lower-cased.
if "$DOTNET" tool list --global | grep -qi "$TOOL"; then
  echo "$TOOL is already installed."
else
  "$DOTNET" tool install --global "$TOOL"
fi

