#!/bin/bash

# EcoLoop Mart - Build Script for All Platforms
# This script builds the app for all supported platforms

set -e

echo "========================================"
echo " EcoLoop Mart - Multi-Platform Builder"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get dependencies
echo -e "${BLUE}[1/7] Getting dependencies...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}Building for all platforms...${NC}"
echo ""

# Android
echo -e "${BLUE}[2/7] Building for Android (APK)...${NC}"
flutter build apk --release
echo -e "${GREEN}✓ Android APK built successfully${NC}"
echo "   Output: build/app/outputs/flutter-apk/app-release.apk"
echo ""

# Android App Bundle (for Play Store)
echo -e "${BLUE}[3/7] Building Android App Bundle...${NC}"
flutter build appbundle --release
echo -e "${GREEN}✓ Android App Bundle built successfully${NC}"
echo "   Output: build/app/outputs/bundle/release/app-release.aab"
echo ""

# Web
echo -e "${BLUE}[4/7] Building for Web...${NC}"
flutter build web --release
echo -e "${GREEN}✓ Web app built successfully${NC}"
echo "   Output: build/web/"
echo ""

# Windows (only on Windows)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "${BLUE}[5/7] Building for Windows...${NC}"
    flutter build windows --release
    echo -e "${GREEN}✓ Windows app built successfully${NC}"
    echo "   Output: build/windows/runner/Release/"
else
    echo -e "${RED}[5/7] Skipping Windows build (not on Windows)${NC}"
fi
echo ""

# macOS (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${BLUE}[6/7] Building for macOS...${NC}"
    flutter build macos --release
    echo -e "${GREEN}✓ macOS app built successfully${NC}"
    echo "   Output: build/macos/Build/Products/Release/"
else
    echo -e "${RED}[6/7] Skipping macOS build (not on macOS)${NC}"
fi
echo ""

# Linux (only on Linux)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${BLUE}[7/7] Building for Linux...${NC}"
    flutter build linux --release
    echo -e "${GREEN}✓ Linux app built successfully${NC}"
    echo "   Output: build/linux/x64/release/bundle/"
else
    echo -e "${RED}[7/7] Skipping Linux build (not on Linux)${NC}"
fi
echo ""

echo "========================================"
echo -e "${GREEN}Build completed!${NC}"
echo "========================================"
echo ""
echo "Output directories:"
echo "  Android APK:      build/app/outputs/flutter-apk/"
echo "  Android Bundle:   build/app/outputs/bundle/release/"
echo "  Web:              build/web/"
echo "  Windows:          build/windows/runner/Release/"
echo "  macOS:            build/macos/Build/Products/Release/"
echo "  Linux:            build/linux/x64/release/bundle/"
echo ""
