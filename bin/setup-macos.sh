#!/bin/bash

set -euo pipefail

echo "Applying macOS defaults..."

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.universalaccess reduceMotion -bool true

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

defaults write -g NSAutoFillHeuristicControllerEnabled -bool false

echo "Restarting affected apps..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "Done."
