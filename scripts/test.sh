#!/bin/sh
set -o pipefail && xcodebuild test -project Bankside.xcodeproj -scheme iOS -sdk iphonesimulator -destination platform='iOS Simulator',OS=10.0,name='iPhone 6' | xcpretty
