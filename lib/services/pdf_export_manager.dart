import 'dart:async';

import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../models/race_model.dart';
import '../ui/dialogs/error_dialog.dart';
import '../ui/dialogs/loading_dialog.dart';
import '../ui/dialogs/success_dialog.dart';
import 'file_share_service.dart';
import 'pdf_export_serivce.dart';

class PdfExportManager {
  static Future<void> exportCharacterWithDialog(
    BuildContext context,
    Character character, {
    String fileName = 'character.pdf',
    String shareText = 'Мой персонаж',
  }) async {
    await _exportWithDialog(
      context,
      () => PdfExportService.createForCharacter(character),
      fileName,
      shareText,
      'персонажа',
    );
  }

  static Future<void> exportRaceWithDialog(
    BuildContext context,
    Race race, {
    String fileName = 'race.pdf',
    String shareText = 'Моя раса',
  }) async {
    await _exportWithDialog(
      context,
      () => PdfExportService.createForRace(race),
      fileName,
      shareText,
      'расы',
    );
  }

  static Future<void> _exportWithDialog(
    BuildContext context,
    Future<PdfExportService> Function() createService,
    String fileName,
    String shareText,
    String entityType,
  ) async {
    try {
      showLoadingDialog(
        context: context,
        message: 'Создание PDF...',
      );

      final pdfService = await createService().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'Создание PDF заняло слишком много времени',
        ),
      );

      final pdfBytes = await pdfService.generatePdf().timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException(
              'Генерация PDF заняла слишком много времени',
            ),
          );

      hideLoadingDialog(context);

      await FileShareService.shareFile(
        pdfBytes,
        fileName,
        text: shareText,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'Шаринг файла занял слишком много времени',
        ),
      );

      showSuccessDialog(
        context: context,
        title: 'Успех!',
        message: 'PDF $entityType успешно создан и готов к分享',
      );
    } on TimeoutException catch (e) {
      hideLoadingDialog(context);
      showErrorDialog(
        context: context,
        title: 'Таймаут',
        message: 'Операция заняла слишком много времени: ${e.message}',
      );
    } catch (e) {
      hideLoadingDialog(context);
      showErrorDialog(
        context: context,
        title: 'Ошибка экспорта',
        message: 'Не удалось создать PDF: ${e.toString()}',
      );
    }
  }
}
