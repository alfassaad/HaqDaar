#!/bin/bash

# Shallow clone Flutter to save time and bandwidth
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Pre-download dependencies
flutter precache --web

# Build the project
flutter build web --release --no-tree-shake-icons

# Ensure the build/web directory exists for Netlify
if [ ! -d "build/web" ]; then
  echo "Build failed: build/web directory not found"
  exit 1
fi
