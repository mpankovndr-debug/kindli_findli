import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class IOSVersion {
  static int _majorVersion = 0;

  /// Call once at app startup
  static Future<void> init() async {
    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      final versionString = iosInfo.systemVersion;
      _majorVersion = int.tryParse(versionString.split('.').first) ?? 0;
    }
  }

  static bool get isIOS26OrLater => _majorVersion >= 26;

  static bool get isIOS18OrLater => _majorVersion >= 18;

  static int get majorVersion => _majorVersion;
}
