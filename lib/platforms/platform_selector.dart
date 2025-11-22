import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/platforms/desktop/desktop_app.dart';
import 'package:characterbook/platforms/mobile/mobile_app.dart';
import 'package:characterbook/platforms/web/web_app.dart';
import 'package:characterbook/core/platform/window_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:characterbook/models/characters/character_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/characters/template_model.dart';
import 'package:characterbook/models/folder_model.dart';

class PlatformSelector {
  static Widget getHomePage() {
    if (kIsWeb) {
      return const WebApp();
    } else if (_isMobilePlatform) {
      return const MobileApp();
    } else {
      return const DesktopAppFrame();
    }
  }

  static bool get _isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }
}

mixin PlatformLifecycleMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);

    if (_isDesktopPlatform && !kIsWeb) {
      WindowService.addListener(this);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    if (_isDesktopPlatform && !kIsWeb) {
      WindowService.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _flushHiveBoxes();
    }
  }

  void onWindowClose() async {
    await _flushHiveBoxes();
    if (!kIsWeb && _isDesktopPlatform) {
      await WindowService.close();
    }
  }

  Future<void> _flushHiveBoxes() async {
    try {
      await Hive.box<Character>('characters').flush();
      await Hive.box<Note>('notes').flush();
      await Hive.box<Race>('races').flush();
      await Hive.box<QuestionnaireTemplate>('templates').flush();
      await Hive.box<Folder>('folders').flush();
    } catch (error) {
      debugPrint('Error flushing Hive boxes: $error');
    }
  }

  bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS;
  }

  void onWindowFocus() {}
  void onWindowBlur() {}
  void onWindowResize() {}
  void onWindowMove() {}
}
