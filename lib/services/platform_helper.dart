import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  static String getServerAddress() {
    if (kIsWeb) {
      // For web platform (Chrome, Firefox, Edge, etc.)
      return "localhost";
    } else {
      // For mobile and desktop platforms
      return _getMobileServerAddress();
    }
  }

  static String _getMobileServerAddress() {
    // This function will be implemented with conditional imports
    // For now, return localhost as fallback
    return "localhost";
  }
}
