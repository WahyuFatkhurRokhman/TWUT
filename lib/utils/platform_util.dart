import 'dart:io';
import 'package:flutter/foundation.dart';

enum SupportedPlatform {
  android,
  windows,
  linux,
  unknown,
}

class PlatformUtil {
  static SupportedPlatform get platform {
    if (kIsWeb) return SupportedPlatform.unknown;

    if (Platform.isAndroid) return SupportedPlatform.android;
    if (Platform.isWindows) return SupportedPlatform.windows;
    if (Platform.isLinux) return SupportedPlatform.linux;

    return SupportedPlatform.unknown;
  }

  static bool get isAndroid => platform == SupportedPlatform.android;
  static bool get isWindows => platform == SupportedPlatform.windows;
  static bool get isLinux => platform == SupportedPlatform.linux;

  static bool get isDesktop => isWindows || isLinux;

  static String get name {
    switch (platform) {
      case SupportedPlatform.android:
        return "android";
      case SupportedPlatform.windows:
        return "windows";
      case SupportedPlatform.linux:
        return "linux";
      default:
        return "unknown";
    }
  }

  static String get localhost {
    if (isAndroid) {
      return "10.0.2.2";
    }
    return "localhost";
  }

  static String get pathSeparator {
    return isWindows ? "\\" : "/";
  }

  static void ensureSupported() {
    if (platform == SupportedPlatform.unknown) {
      throw UnsupportedError("Platform tidak didukung");
    }
  }
}