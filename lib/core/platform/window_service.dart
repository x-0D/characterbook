import 'dart:io';
import 'package:flutter/foundation.dart';
import 'window_service_interface.dart';
import 'desktop_window_service.dart';
import 'web_window_service.dart';

class WindowService {
  static WindowServiceInterface? _instance;

  static WindowServiceInterface get _service {
    _instance ??= _createService();
    return _instance!;
  }

  static WindowServiceInterface _createService() {
    if (kIsWeb) {
      return WebWindowService();
    } else if (_isDesktopPlatform) {
      return DesktopWindowService();
    } else {
      return WebWindowService();
    }
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;

    await _service.initialize();
  }

  static Future<void> minimize() async {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;
    await _service.minimize();
  }

  static Future<void> toggleMaximize() async {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;
    await _service.toggleMaximize();
  }

  static Future<void> close() async {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;
    await _service.close();
  }

  static Future<bool> isMaximized() async {
    if (kIsWeb) return false;
    if (!_isDesktopPlatform) return false;
    return await _service.isMaximized();
  }

  static void addListener(dynamic listener) {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;
    _service.addListener(listener);
  }

  static void removeListener(dynamic listener) {
    if (kIsWeb) return;
    if (!_isDesktopPlatform) return;
    _service.removeListener(listener);
  }

  static bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS;
  }
}
