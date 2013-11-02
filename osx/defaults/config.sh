#!/bin/bash

# dockを自動的に隠す
defaults write com.apple.dock autohide -bool true
# Dashboardを無効化
defaults write com.apple.dashboard mcx-disabled -bool true
# 隠しファイルを表示
defaults write com.apple.dock showhidden -bool true

# Finderをリスト表示
defaults write com.apple.Finder FXPreferredViewStyle Nlsv
# パスバーを出す
defaults write com.apple.Finder ShowPathbar -bool true
# ステータスバーを出す
defaults write com.apple.Finder ShowStatusBar -bool true

# スペルチェックを無効に
defaults write -g NSAllowContinuousSpellChecking -bool false

# Trackpadをタップでクリック
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# remoteで.DS_Storeを作成しないように
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
