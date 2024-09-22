#!/bin/bash

APP_NAME="Metal HUD"
APP_DIR="$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"
INFO_PLIST="$APP_DIR/Contents/Info.plist"
ICON_FILE="AppIcon.icns"

if [ -d "$APP_DIR" ]; then
    echo "Deleting existing $APP_DIR..."
    rm -rf "$APP_DIR"
fi

echo "Creating $APP_DIR structure..."
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

echo "Copying icon file..."
cp "$ICON_FILE" "$RESOURCES_DIR/"

echo "Creating Info.plist..."
cat <<EOF > "$INFO_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>me.iipho3nix.$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

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
