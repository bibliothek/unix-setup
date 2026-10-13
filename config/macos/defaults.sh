#!/bin/bash

echo "Configuring macOS defaults..."

# System-wide short and medium date styles, e.g. in Finder columns. ICU 'y'
# already renders a four-digit year, so this is yyyy-MM-dd. -dict-add merges
# rather than replacing, leaving the long and full styles alone. Applications
# pick it up as they are launched.
#
# The menu bar clock does not follow this and has no format setting of its own
# on current macOS: ControlCenter renders it from a built-in locale template
# and the old com.apple.menuextra.clock DateFormat key is ignored (verified on
# macOS 26.6).
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add 1 "y-MM-dd" 2 "y-MM-dd"

# disable press and hold for rider to work with ideavim
defaults write com.jetbrains.rider ApplePressAndHoldEnabled -bool false

defaults write com.apple.dock autohide-delay -float 0

# Dock shows running applications only, never pinned ones. Restarting the Dock
# is what makes that visible, so only do it when the setting is not already in
# place - this runs on every setup run.
if [ "$(defaults read com.apple.dock static-only 2> /dev/null)" = "1" ]; then
  echo "Dock already shows open applications only."
else
  defaults write com.apple.dock static-only -bool true
  killall Dock &> /dev/null
  echo "Dock now shows open applications only."
fi
