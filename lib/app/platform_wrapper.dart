import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:characterbook/services/hive_service.dart';
import 'package:characterbook/handlers/file_handler.dart';
import 'package:characterbook/core/platform/window_service.dart';

import '../models/characters/character_model.dart';
import '../models/characters/template_model.dart';
import '../models/folder_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';

class PlatformWrapper {
  static Future<void> initializePlatform() async {
    await _initializeHive();

    if (!kIsWeb && _isDesktopPlatform) {
      await WindowService.initialize();
    }

    await FileHandler.initialize();
  }

  static Future<void> _initializeHive() async {
    try {
      await HiveService.initHive();
      await Future.wait([
        HiveService.getBox<Character>('characters'),
        HiveService.getBox<Note>('notes'),
        HiveService.getBox<Race>('races'),
        HiveService.getBox<QuestionnaireTemplate>('templates'),
        HiveService.getBox<Folder>('folders'),
      ]);
    } catch (error) {
      debugPrint('Hive initialization error: $error');
    }
  }

  static bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS;
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
