import 'package:characterbook/models/characters/character_model.dart';
import 'package:characterbook/models/settings/export_pdf_settings_model.dart';
import 'package:characterbook/services/export_pdf_settings_service.dart';
import 'package:characterbook/services/pdf_export_serivce.dart';

class PdfExportFactory {
  static Future<PdfExportService> createForCharacter(
      Character character) async {
    final settingsService = ExportPdfSettingsService();
    final settings = await settingsService.getSettings();

    return PdfExportService(
      character: character,
      settings: settings,
    );
  }

  static Future<PdfExportService> createWithCustomSettings(
    Character character,
    ExportPdfSettings settings,
  ) async {
    return PdfExportService(
      character: character,
      settings: settings,
    );
  }
}
