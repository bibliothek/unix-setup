#!/bin/bash

# dotnet-install.sh drops the SDK in $HOME/.dotnet, which is not on PATH until a
# new shell picks it up, so look there too before deciding anything is missing.
if command -v dotnet &> /dev/null; then
  DOTNET=dotnet
elif [ -x "${DOTNET_ROOT:-$HOME/.dotnet}/dotnet" ]; then
  DOTNET="${DOTNET_ROOT:-$HOME/.dotnet}/dotnet"
fi

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

if [ ${#MISSING[@]} -eq 0 ]; then
  exit 0
fi

curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh

for CHANNEL in "${MISSING[@]}"; do
  ./dotnet-install.sh --channel "$CHANNEL"
done

rm ./dotnet-install.sh
