import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../models/character_model.dart';
import '../models/template_model.dart';
import '../models/folder_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';
import '../models/export_pdf_settings_model.dart';
import 'hive_service.dart';

class InitializationService {
  static bool get isDesktopPlatform =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS);

  static bool get isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> initializeHive() async {
    try {
      await HiveService.initHive();
      await Future.wait([
        HiveService.getBox<Character>('characters'),
        HiveService.getBox<Note>('notes'),
        HiveService.getBox<Race>('races'),
        HiveService.getBox<QuestionnaireTemplate>('templates'),
        HiveService.getBox<Folder>('folders'),
        HiveService.getBox<ExportPdfSettings>('pdf_settings'),
      ]);
      return true;
    } catch (error) {
      debugPrint('Hive initialization error: $error');
      await HiveService.resetAndReinitialize();
      return false;
    }
  }

  static Future<void> initializeWindowManager() async {
    if (!isDesktopPlatform) return;

    try {
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
    } catch (error) {
      debugPrint('Window manager initialization error: $error');
      rethrow;
    }
  }
}

class InitializationError {
  final String title;
  final String message;
  final bool requiresReset;

  InitializationError({
    required this.title,
    required this.message,
    this.requiresReset = false,
  });
}

class ErrorDialogService {
  static Future<void> showInitializationErrorDialog(
    BuildContext context, {
    required InitializationError error,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(error.title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error.message),
              if (error.requiresReset) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Приложение сбросило некоторые данные и настройки для восстановления работоспособности',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Понятно'),
            ),
            if (error.requiresReset)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Подробнее'),
              ),
          ],
        );
      },
    );
  }

  static Future<void> showCriticalErrorDialog(
    BuildContext context, {
    required String message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Критическая ошибка'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Приложение попыталось восстановить работоспособность, но некоторые данные могли быть утеряны',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (InitializationService.isDesktopPlatform) {
                  exit(0);
                }
              },
              child: const Text('Закрыть приложение'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }
}
