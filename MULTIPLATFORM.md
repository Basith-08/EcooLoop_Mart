# EcoLoop Mart - Multi-Platform Guide

## 🌐 Supported Platforms

EcoLoop Mart now supports **ALL Flutter platforms**:

| Platform | Status | Database | Notes |
|----------|--------|----------|-------|
| 📱 **Android** | ✅ Full Support | SQLite (sqflite) | Tested on Android 5.0+ |
| 🍎 **iOS** | ✅ Full Support | SQLite (sqflite) | Tested on iOS 12+ |
| 🌍 **Web** | ✅ Full Support | IndexedDB (sqflite_ffi_web) | Works in Chrome, Firefox, Safari |
| 🪟 **Windows** | ✅ Full Support | SQLite FFI | Windows 10+ |
| 🍏 **macOS** | ✅ Full Support | SQLite FFI | macOS 10.14+ |
| 🐧 **Linux** | ✅ Full Support | SQLite FFI | Ubuntu 20.04+, Fedora, etc. |

---

## 📦 Installation by Platform

### Prerequisites for All Platforms
- Flutter SDK >= 3.0.0
- Git

### Platform-Specific Requirements

#### Android
```bash
# Install Android Studio
# Install Android SDK (API 21+)
# Install Android Emulator or connect physical device
```

#### iOS (macOS only)
```bash
# Install Xcode from App Store
# Install CocoaPods
sudo gem install cocoapods
```

#### Web
```bash
# Chrome browser recommended
# No additional requirements
```

#### Windows
```bash
# Visual Studio 2022 with C++ Desktop Development
# Windows 10 SDK
```

#### macOS
```bash
# Xcode Command Line Tools
xcode-select --install
```

#### Linux
```bash
# Install required libraries
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

---

## 🚀 Running on Different Platforms

### Quick Start Commands

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Web
```bash
# Run in Chrome
flutter run -d chrome

# Or use the script
./scripts/run_web.sh
```

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

### List Available Devices
```bash
flutter devices
```

---

## 🔨 Building for Production

### Using Build Scripts (Recommended)

#### Linux/macOS
```bash
# Build all platforms (runs platform-specific builds)
./scripts/build_all.sh

# Web only
./scripts/run_web.sh
```

#### Windows
```batch
REM Build Web
scripts\build_web.bat

REM Build Windows Desktop
scripts\build_desktop.bat
```

### Manual Build Commands

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

#### Web
```bash
flutter build web --release
# Output: build/web/
```

#### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/ecoloop_mart.exe
```

#### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/ecoloop_mart.app
```

#### Linux
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

---

## 🗄️ Database Per Platform

### Mobile (Android/iOS)
- **Engine**: SQLite via sqflite
- **Location**: Device app directory
- **Size**: ~100 KB (empty) to several MB
- **Persistence**: Local storage, survives app restart

### Web
- **Engine**: IndexedDB via sqflite_ffi_web
- **Location**: Browser storage
- **Size**: Limited by browser (usually 50+ MB available)
- **Persistence**: Persistent per browser/domain
- **Note**: Cleared if user clears browser data

### Desktop (Windows/macOS/Linux)
- **Engine**: SQLite via sqflite_common_ffi
- **Location**: User documents folder
  - Windows: `C:\Users\<username>\Documents\ecoloop_mart_db\`
  - macOS: `/Users/<username>/Documents/ecoloop_mart_db/`
  - Linux: `/home/<username>/Documents/ecoloop_mart_db/`
- **Size**: Unlimited (system disk space)
- **Persistence**: Permanent until manually deleted
- **Backup**: Can be backed up using `DBHelper().backupDatabase()`

---

## 🎨 Responsive Design

### Screen Breakpoints

| Size | Range | Platform | Grid Columns |
|------|-------|----------|--------------|
| **Mobile** | 0-450px | Phone portrait | 2 |
| **Tablet** | 451-800px | Tablet/Phone landscape | 3 |
| **Desktop** | 801-1920px | Desktop/Laptop | 4 |
| **4K** | 1921px+ | Large displays | 4 |

### Adaptive UI Features

#### Mobile (Android/iOS)
- Bottom navigation bar
- Full-screen dialogs
- Swipe gestures
- Touch-optimized buttons
- Compact spacing

#### Tablet
- Larger grid (3 columns)
- Medium dialogs
- More spacing
- Larger touch targets

#### Desktop (Windows/macOS/Linux)
- Large grid (4 columns)
- Constrained dialogs (max 600px)
- Keyboard shortcuts
- Hover effects
- Window resizing (min 800x600)

#### Web
- Responsive to viewport
- Works on mobile browsers
- Desktop-like on large screens
- PWA support (installable)

### Using Responsive Utilities

```dart
import 'package:ecoloop_mart/core/utils/responsive_utils.dart';

// Check platform
if (ResponsiveUtils.isMobile(context)) {
  // Mobile-specific UI
}

if (ResponsiveUtils.isDesktop(context)) {
  // Desktop-specific UI
}

// Get responsive values
final padding = ResponsiveUtils.getResponsiveValue(
  context,
  mobile: 12.0,
  tablet: 16.0,
  desktop: 24.0,
);

// Grid columns
final columns = ResponsiveUtils.getGridColumns(context);
// Returns: 2 (mobile), 3 (tablet), 4 (desktop)
```

---

## 🌐 Web-Specific Features

### Progressive Web App (PWA)
The web version can be installed as a PWA:

1. Open in Chrome/Edge
2. Click install icon in address bar
3. App appears like native app
4. Works offline (cached)

### Serving Locally
```bash
# Build first
flutter build web --release

# Serve with Python
cd build/web
python3 -m http.server 8000

# Or with Node.js
npx http-server build/web -p 8000
```

### Web Limitations
- No file system access
- No native notifications
- Database cleared with browser data
- Limited to browser permissions

---

## 🖥️ Desktop-Specific Features

### Window Management

#### Default Window Size
- **Size**: 1280x800 pixels
- **Minimum**: 800x600 pixels
- **Centered**: Yes
- **Resizable**: Yes

#### Customizing Window (main.dart)
```dart
const WindowOptions windowOptions = WindowOptions(
  size: Size(1280, 800),
  minimumSize: Size(800, 600),
  center: true,
  title: 'EcoLoop Mart',
);
```

### Desktop Features
- ✅ Window resizing
- ✅ Minimize/Maximize/Close
- ✅ System tray support (can be added)
- ✅ File system access
- ✅ Database backup to disk
- ✅ Keyboard shortcuts

### Keyboard Shortcuts (Future)
```
Ctrl/Cmd + Q  - Quit
Ctrl/Cmd + R  - Refresh data
Ctrl/Cmd + N  - New item
Ctrl/Cmd + S  - Save
```

---

## 📱 Mobile-Specific Features

### Android
- ✅ System back button support
- ✅ Share functionality
- ✅ Notifications (can be added)
- ✅ Material Design 3
- ✅ Adaptive icons

### iOS
- ✅ Cupertino widgets (can be added)
- ✅ Safe area handling
- ✅ Swipe gestures
- ✅ iOS app icons

---

## 🔧 Troubleshooting by Platform

### Android
**Issue**: App won't install
```bash
# Clear app data
flutter clean
flutter pub get
flutter run
```

**Issue**: Database error
```bash
# Uninstall app and reinstall
flutter run --uninstall-first
```

### iOS
**Issue**: Build fails
```bash
# Clean iOS build
cd ios
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Web
**Issue**: White screen
- Check browser console (F12)
- Clear browser cache
- Rebuild: `flutter build web --release`

**Issue**: Database not persisting
- Check if private/incognito mode
- Check browser storage settings

### Windows
**Issue**: Missing DLLs
- Install Visual Studio 2022 with C++ tools
- Install Windows SDK

### macOS
**Issue**: Code signing error
- Open in Xcode and sign manually
- Or disable signing for development

### Linux
**Issue**: Missing libraries
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

---

## 📊 Platform Comparison

| Feature | Mobile | Web | Desktop |
|---------|--------|-----|---------|
| Database | SQLite | IndexedDB | SQLite |
| File System | Limited | No | Full |
| Offline | ✅ | Partial | ✅ |
| Install Size | ~20 MB | N/A | ~100 MB |
| Auto-update | Store | Instant | Manual |
| Performance | Excellent | Good | Excellent |
| Permissions | System | Browser | System |

---

## 🚢 Deployment

### Android (Google Play)
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Play Console
3. Fill store listing
4. Submit for review

### iOS (App Store)
1. Build iOS: `flutter build ios --release`
2. Open in Xcode
3. Archive and upload
4. Submit via App Store Connect

### Web (Hosting)
```bash
# Build
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy

# Or Netlify, Vercel, GitHub Pages, etc.
```

### Windows (Microsoft Store)
1. Build MSIX: `flutter build windows --release`
2. Package as MSIX
3. Upload to Partner Center

### macOS (App Store)
1. Build macOS: `flutter build macos --release`
2. Package as PKG
3. Submit via App Store Connect

### Linux (Snap Store / Flathub)
1. Build Linux: `flutter build linux --release`
2. Package as Snap or Flatpak
3. Upload to respective store

---

## 🎯 Best Practices

### Development
- Test on at least 2 platforms
- Use responsive utils for layouts
- Handle platform-specific code with `kIsWeb` and `Platform.is...`
- Test on different screen sizes

### Database
- Always check database compatibility
- Handle migrations properly
- Backup important data on desktop
- Clear web storage for testing

### Performance
- Mobile: Optimize images, lazy load
- Web: Code splitting, caching
- Desktop: Use native widgets where possible

### Testing
```bash
# Test on all available devices
flutter devices
flutter run -d <device-id>

# Run tests
flutter test

# Integration tests per platform
flutter drive --target=test_driver/app.dart
```

---

## 📚 Additional Resources

- [Flutter Multi-Platform Docs](https://docs.flutter.dev/deployment)
- [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
- [window_manager](https://pub.dev/packages/window_manager)
- [responsive_framework](https://pub.dev/packages/responsive_framework)

---

**Now you can run EcoLoop Mart on any platform!** 🎉

Choose your platform and start building! 🚀
