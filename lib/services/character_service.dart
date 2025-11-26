import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/character_model.dart';
import 'pdf_export_serivce.dart';
import 'file_share_service.dart';

class CharacterService {
  static const String _boxName = 'characters';

  final Character? character;

  CharacterService.forDatabase() : character = null;

  CharacterService.forExport(this.character);

  Future<Box<Character>> get _box => Hive.openBox<Character>(_boxName);

  Future<int?> saveCharacter(Character character, {int? key}) async {
    final box = Hive.box<Character>('characters');
    if (key != null) {
      await box.put(key, character);
      return key;
    } else {
      return await box.add(character);
    }
  }

  Future<void> deleteCharacter(Character character) async {
    final box = await _box;

    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == character.id,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);
    }
  }

  Future<List<Character>> getAllCharacters() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> exportToPdf(BuildContext context) async {
    bool isLoadingVisible = false;

    if (character == null) {
      throw Exception("Character is not set for export");
    }

    try {
      isLoadingVisible = true;
      showLoadingDialog(context: context, message: S.of(context).creating_pdf);

      final bytes = await _generatePdfWithTimeout();

      if (context.mounted) {
        hideLoadingDialog(context);
        isLoadingVisible = false;
      }

      await Future.delayed(const Duration(milliseconds: 200));
      await FileShareService.shareFile(
        bytes,
        '${character!.name}.pdf',
        text: 'Характеристика персонажа ${character!.name}',
        subject: 'PDF с характеристикой персонажа',
      );
    } catch (e) {
      if (isLoadingVisible && context.mounted) {
        hideLoadingDialog(context);
      }
      _showErrorDialog(context, 'Ошибка экспорта в PDF: ${e.toString()}');
    }
  }

  Future<Uint8List> _generatePdfWithTimeout() async {
    try {
      final pdfService = await PdfExportService.createForCharacter(character!);

      return await pdfService.generatePdf().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Генерация PDF заняла слишком много времени');
        },
      );
    } catch (e) {
      throw Exception('Ошибка при создании PDF: ${e.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> exportToJson(BuildContext context) async {
    if (character == null) throw Exception("Character is not set for export");

    bool isLoadingVisible = false;

    try {
      isLoadingVisible = true;
      showLoadingDialog(context: context, message: S.of(context).creating_file);
      await Future.delayed(const Duration(milliseconds: 50));

      final jsonStr = jsonEncode(character!.toJson());
      final fileName =
          '${character!.name}_${DateTime.now().millisecondsSinceEpoch}.character';

      if (context.mounted) {
        hideLoadingDialog(context);
        isLoadingVisible = false;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      await FileShareService.shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Персонаж: ${character!.name}',
      );
    } catch (e) {
      if (isLoadingVisible && context.mounted) {
        hideLoadingDialog(context);
      }
      throw Exception('Ошибка экспорта в JSON: ${e.toString()}');
    }
  }
}
