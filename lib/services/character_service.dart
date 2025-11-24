// [file name]: character_service.dart (упрощенная версия)
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import '../models/characters/character_model.dart';
import '../services/export_pdf_settings_service.dart';
import 'pdf_export_serivce.dart';

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

  Future<List<Character>> getAllCharacters() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> deleteCharacter(int key) async {
    final box = await _box;
    await box.delete(key);
  }

  Future<void> exportToPdf(BuildContext context) async {
    if (character == null) throw Exception("Character is not set for export");

    showLoadingDialog(context: context, message: S.of(context).creating_pdf);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final settingsService = ExportPdfSettingsService();
      final settings = await settingsService.getSettings();

      final pdfService = PdfExportService(
        character: character!,
        settings: settings,
      );

      final bytes = await pdfService.generatePdf();

      hideLoadingDialog(context);
      await _sharePdf(bytes);
    } catch (e) {
      hideLoadingDialog(context);
      throw Exception('Ошибка экспорта в PDF: ${e.toString()}');
    }
  }

  Future<void> exportToJson(BuildContext context) async {
    if (character == null) throw Exception("Character is not set for export");

    showLoadingDialog(context: context, message: S.of(context).creating_file);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final jsonStr = jsonEncode(character!.toJson());
      final fileName =
          '${character!.name}_${DateTime.now().millisecondsSinceEpoch}.character';

      hideLoadingDialog(context);

      await _shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Персонаж: ${character!.name}',
      );
    } catch (e) {
      hideLoadingDialog(context);
      throw Exception('Ошибка экспорта в JSON: ${e.toString()}');
    }
  }

  Future<void> _sharePdf(Uint8List bytes) async {
    await _shareFile(
      bytes,
      '${character!.name}.pdf',
      text: 'Характеристика персонажа ${character!.name}',
      subject: 'PDF с характеристикой персонажа',
    );
  }

  Future<void> _shareFile(Uint8List bytes, String fileName,
      {String? text, String? subject}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
      subject: subject,
    );
  }
}
