#!/bin/sh

# Set variables
GENERATE_ZIP=false
BUILD_PATH="./build"

# Set options based on user input
if [ -z "$1" ]; then
  GENERATE_ZIP="$1"
fi

# If not configured defaults to repository name
if [ -z "$PLUGIN_SLUG" ]; then
  PLUGIN_SLUG=${GITHUB_REPOSITORY#*/}
fi

# Set GitHub "path" output
DEST_PATH="$BUILD_PATH/$PLUGIN_SLUG"
echo "::set-output name=path::$DEST_PATH"

cd "$GITHUB_WORKSPACE" || exit

# Detect package manager based on lock files
if [ -f "pnpm-lock.yaml" ]; then
  PACKAGE_MANAGER="pnpm"
  INSTALL_CMD="pnpm install"
  RUN_CMD="pnpm run"
else
  PACKAGE_MANAGER="npm"
  INSTALL_CMD="npm install"
  RUN_CMD="npm run"
fi

echo "Detected package manager: $PACKAGE_MANAGER"
echo "Installing PHP and JS dependencies..."
$INSTALL_CMD
composer install || exit "$?"
echo "Running JS Build..."
$RUN_CMD build || exit "$?"
echo "Cleaning up PHP dependencies..."
composer install --no-dev || exit "$?"

echo "Generating build directory..."
rm -rf "$BUILD_PATH"
mkdir -p "$DEST_PATH"

if [ -r "${GITHUB_WORKSPACE}/.distignore" ]; then
  rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete --delete-excluded
else
  rsync -rc "$GITHUB_WORKSPACE/" "$DEST_PATH/" --delete
fi

if ! $GENERATE_ZIP; then
  echo "Generating zip file..."
  cd "$BUILD_PATH" || exit
  zip -r "${PLUGIN_SLUG}.zip" "$PLUGIN_SLUG/"
  # Set GitHub "zip_path" output
  echo "::set-output name=zip_path::$BUILD_PATH/${PLUGIN_SLUG}.zip"
  echo "Zip file generated!"
fi

echo "Build done!"
