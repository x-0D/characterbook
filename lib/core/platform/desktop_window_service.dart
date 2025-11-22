import 'dart:ui';

import 'package:window_manager/window_manager.dart';
import 'window_service_interface.dart';

class DesktopWindowService implements WindowServiceInterface {
  @override
  Future<void> initialize() async {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow();

    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.center();
    await windowManager.show();
  }

  @override
  Future<void> minimize() async => await windowManager.minimize();

  @override
  Future<void> toggleMaximize() async {
    final isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Future<void> close() async => await windowManager.close();

  @override
  Future<bool> isMaximized() async => await windowManager.isMaximized();

  @override
  void addListener(dynamic listener) =>
      windowManager.addListener(listener as WindowListener);

  @override
  void removeListener(dynamic listener) =>
      windowManager.removeListener(listener as WindowListener);
}
