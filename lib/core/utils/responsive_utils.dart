import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utility class for responsive design across platforms
class ResponsiveUtils {
  /// Check if running on mobile (Android/iOS)
  static bool isMobile(BuildContext context) {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if running on desktop (Windows/macOS/Linux)
  static bool isDesktop(BuildContext context) {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Check if running on web
  static bool isWeb() {
    return kIsWeb;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is small (mobile portrait)
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 600;
  }

  /// Check if screen is medium (tablet or mobile landscape)
  static bool isMediumScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= 600 && width < 1200;
  }

  /// Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isLargeScreen(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isMediumScreen(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Get grid columns count based on screen size
  static int getGridColumns(BuildContext context) {
    if (isLargeScreen(context)) {
      return 4; // Desktop: 4 columns
    } else if (isMediumScreen(context)) {
      return 3; // Tablet: 3 columns
    }
    return 2; // Mobile: 2 columns
  }

  /// Get card width for list/grid items
  static double getCardWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isLargeScreen(context)) {
      return (width - 64) / 4; // 4 columns with padding
    } else if (isMediumScreen(context)) {
      return (width - 48) / 3; // 3 columns
    }
    return (width - 32) / 2; // 2 columns
  }

  /// Get padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isLargeScreen(context)) {
      return const EdgeInsets.all(24);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(12);
  }

  /// Get dialog constraints based on screen size
  static BoxConstraints getDialogConstraints(BuildContext context) {
    if (isLargeScreen(context)) {
      return const BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      );
    } else if (isMediumScreen(context)) {
      return const BoxConstraints(
        maxWidth: 500,
        maxHeight: 700,
      );
    }
    return BoxConstraints(
      maxWidth: screenWidth(context) * 0.9,
      maxHeight: screenHeight(context) * 0.8,
    );
  }

  /// Show platform-appropriate dialog
  static Future<T?> showPlatformDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    if (isDesktop(context) || isWeb()) {
      // Desktop/Web: Use constrained dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: getDialogConstraints(context),
            child: builder(context),
          ),
        ),
      );
    } else {
      // Mobile: Use full screen dialog for better UX
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
    }
  }

  /// Get text scale based on platform
  static double getTextScale(BuildContext context) {
    if (isDesktop(context)) {
      return 1.0; // Normal scale on desktop
    }
    return MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }

  /// Get font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isLargeScreen(context)) {
      return 1.1; // Slightly larger on desktop
    } else if (isMediumScreen(context)) {
      return 1.0;
    }
    return 0.95; // Slightly smaller on mobile
  }

  /// Check if should use bottom navigation or drawer
  static bool shouldUseBottomNavigation(BuildContext context) {
    return !isDesktop(context) && !isWeb();
  }

  /// Check if should use side navigation (drawer/rail)
  static bool shouldUseSideNavigation(BuildContext context) {
    return isDesktop(context) || (isWeb() && isLargeScreen(context));
  }

  /// Get maximum content width for desktop
  static double getMaxContentWidth(BuildContext context) {
    if (isLargeScreen(context)) {
      return 1400; // Max width on large screens
    }
    return double.infinity;
  }

  /// Check if keyboard is visible (mobile only)
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Check if landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }
}
