#!/bin/bash

APP_NAME="MetalHUDApp"
APP_DIR="$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"

if [ -d "$APP_DIR" ]; then
    echo "Deleting existing $APP_DIR..."
    rm -rf "$APP_DIR"
fi

echo "Creating $APP_DIR structure..."
mkdir -p "$MACOS_DIR"

echo "Compiling Swift code..."
swiftc -o "$MACOS_DIR/$APP_NAME" -framework Cocoa MetalHUDApp.swift

if [ $? -eq 0 ]; then
    echo "$APP_NAME compiled successfully."
else
    echo "Compilation failed."
    exit 1
fi

echo "Build complete. You can run the app using:"
echo "open $APP_DIR"

