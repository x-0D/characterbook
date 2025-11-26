import 'package:characterbook/models/characters/character_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/settings/export_pdf_settings_model.dart';
import 'package:characterbook/models/settings/exportable_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class PdfExportService {
  static const String _regularFontPath = 'assets/fonts/NotoSans-Regular.ttf';
  static const String _boldFontPath = 'assets/fonts/NotoSans-Bold.ttf';
  static const String _settingsKey = 'export_pdf_settings';

  final ExportableModel model;
  final ExportPdfSettings settings;

  PdfExportService({
    required this.model,
    required this.settings,
  });

  static Future<PdfExportService> createForCharacter(
      Character character) async {
    final settingsService = ExportPdfSettingsService();
    final settings = await settingsService.getSettings();
    return PdfExportService(model: character, settings: settings);
  }

  static Future<PdfExportService> createForRace(Race race) async {
    final settingsService = ExportPdfSettingsService();
    final settings = await settingsService.getSettings();
    return PdfExportService(model: race, settings: settings);
  }

  static Future<PdfExportService> createWithCustomSettings(
    ExportableModel model,
    ExportPdfSettings settings,
  ) async {
    return PdfExportService(model: model, settings: settings);
  }

  Future<Uint8List> generatePdf() async {
    final font = await _loadFont(_regularFontPath);
    final boldFont = await _loadFont(_boldFontPath);
    final theme = pw.ThemeData.withFont(base: font, bold: boldFont);

    final pdf = pw.Document();
    final exportData = model.toExportMap();

    _addMainPage(pdf, theme, exportData);
    _addOptionalSections(pdf, theme, exportData);

    return await pdf.save();
  }

  void _addMainPage(
      pw.Document pdf, pw.ThemeData theme, Map<String, dynamic> data) {
    if (!settings.includeBasicInfo) return;

    final isCharacter = data['type'] == 'character';
    final title = isCharacter ? 'Характеристика персонажа' : 'Описание расы';

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: settings.titleFontSize,
                fontWeight: pw.FontWeight.bold,
                color: _parsePdfColor(settings.titleColor),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          if (data['mainImage'] != null && settings.includeCharacterImage) ...[
            _buildImage(data['mainImage']!),
            pw.SizedBox(height: 20),
          ],
          _buildBasicInfoSection(data, isCharacter),
        ],
      ),
    );
  }

  pw.Widget _buildBasicInfoSection(
      Map<String, dynamic> data, bool isCharacter) {
    final details = data['details'] as Map<String, dynamic>;
    final infoRows = <pw.Widget>[
      _buildInfoRow('Название:', data['name']),
    ];

    if (isCharacter) {
      infoRows.addAll([
        if (details['age'] != null && details['age'].toString().isNotEmpty)
          _buildInfoRow('Возраст:', details['age'].toString()),
        if (details['gender'] != null &&
            details['gender'].toString().isNotEmpty)
          _buildInfoRow('Пол:', details['gender']),
        if (details['race'] != null && details['race'].toString().isNotEmpty)
          _buildInfoRow('Раса:', details['race']),
      ]);
    }

    if (data['description'] != null &&
        data['description'].toString().isNotEmpty) {
      infoRows.add(_buildInfoRow('Описание:', data['description']));
    }

    return _buildSection('Основная информация', infoRows);
  }

  void _addOptionalSections(
      pw.Document pdf, pw.ThemeData theme, Map<String, dynamic> data) {
    final isCharacter = data['type'] == 'character';
    final details = data['details'] as Map<String, dynamic>;

    if (isCharacter) {
      _addCharacterSections(pdf, theme, details);
    } else {
      _addRaceSections(pdf, theme, details);
    }

    if (settings.includeCustomFields && details['customFields'] != null) {
      _addCustomFieldsSection(pdf, theme, details['customFields']);
    }

    if (settings.includeAdditionalImages && data['additionalImages'] != null) {
      _addAdditionalImagesSection(pdf, theme, data['additionalImages']);
    }
  }

  void _addCharacterSections(
      pw.Document pdf, pw.ThemeData theme, Map<String, dynamic> details) {
    final sections = [
      _Section('Биография', details['biography'], settings.includeBiography),
      _Section('Характер', details['personality'], settings.includePersonality),
      _Section('Внешность', details['appearance'], settings.includeAppearance),
      _Section('Способности', details['abilities'], settings.includeAbilities),
      _Section('Другое', details['other'], settings.includeOther),
    ];

    for (final section in sections) {
      if (section.include && section.content.isNotEmpty) {
        _addTextSection(pdf, theme, section.title, section.content);
      }
    }

    if (settings.includeReferenceImage && details['referenceImage'] != null) {
      _addImageSection(
          pdf, theme, 'Референс изображение', details['referenceImage']!);
    }
  }

  void _addRaceSections(
      pw.Document pdf, pw.ThemeData theme, Map<String, dynamic> details) {
    final sections = [
      _Section('Биология', details['biology'], settings.includeBiography),
      _Section('История', details['backstory'], settings.includePersonality),
      _Section('Описание', details['description'], settings.includeAppearance),
    ];

    for (final section in sections) {
      if (section.include && section.content.isNotEmpty) {
        _addTextSection(pdf, theme, section.title, section.content);
      }
    }
  }

  void _addTextSection(
      pw.Document pdf, pw.ThemeData theme, String title, String content) {
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) => [
          pw.Header(
            level: 1,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: settings.titleFontSize,
                color: _parsePdfColor(settings.titleColor),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            content,
            softWrap: true,
            style: pw.TextStyle(
              fontSize: settings.bodyFontSize,
              color: _parsePdfColor(settings.bodyColor),
            ),
          ),
        ],
      ),
    );
  }

  void _addImageSection(
      pw.Document pdf, pw.ThemeData theme, String title, Uint8List imageBytes) {
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) => [
          pw.Header(
            level: 1,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: settings.titleFontSize,
                color: _parsePdfColor(settings.titleColor),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildImage(imageBytes),
        ],
      ),
    );
  }

  void _addCustomFieldsSection(
      pw.Document pdf, pw.ThemeData theme, List<dynamic> customFields) {
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) => [
          pw.Header(
            level: 1,
            child: pw.Text(
              'Дополнительные поля',
              style: pw.TextStyle(
                fontSize: settings.titleFontSize,
                color: _parsePdfColor(settings.titleColor),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          ...customFields.map(
              (field) => _buildInfoRow('${field['key']}:', field['value'])),
        ],
      ),
    );
  }

  void _addAdditionalImagesSection(
      pw.Document pdf, pw.ThemeData theme, List<Uint8List> images) {
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) => [
          pw.Header(
            level: 1,
            child: pw.Text(
              'Дополнительные изображения',
              style: pw.TextStyle(
                fontSize: settings.titleFontSize,
                color: _parsePdfColor(settings.titleColor),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          ...images.map((imageBytes) => pw.Column(
              children: [_buildImage(imageBytes), pw.SizedBox(height: 20)])),
        ],
      ),
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 15),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: settings.titleFontSize,
            fontWeight: pw.FontWeight.bold,
            color: _parsePdfColor(settings.titleColor),
          ),
        ),
        pw.Divider(),
        ...children,
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: settings.bodyFontSize,
              color: _parsePdfColor(settings.bodyColor),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              softWrap: true,
              style: pw.TextStyle(
                fontSize: settings.bodyFontSize,
                color: _parsePdfColor(settings.bodyColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildImage(Uint8List bytes) {
    return pw.Center(
      child: pw.Image(
        pw.MemoryImage(bytes),
        fit: pw.BoxFit.contain,
        width: 300,
        height: 300,
      ),
    );
  }

  Future<pw.Font> _loadFont(String path) async {
    try {
      final fontData = await rootBundle.load(path);
      return pw.Font.ttf(fontData);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки шрифта $path: $e');
      }
      return pw.Font.courier();
    }
  }

  pw.PdfColor _parsePdfColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      final r = int.parse(hexColor.substring(0, 2), radix: 16) / 255;
      final g = int.parse(hexColor.substring(2, 4), radix: 16) / 255;
      final b = int.parse(hexColor.substring(4, 6), radix: 16) / 255;
      return pw.PdfColor(r, g, b);
    } else {
      return pw.PdfColor(0, 0, 0);
    }
  }
}

class _Section {
  final String title;
  final String content;
  final bool include;

  _Section(this.title, this.content, this.include);
}

class ExportPdfSettingsService {
  static const String _boxName = 'export_pdf_settings';
  static const String _settingsKey = 'settings';

  Future<Box<ExportPdfSettings>> get _box =>
      Hive.openBox<ExportPdfSettings>(_boxName);

  Future<ExportPdfSettings> getSettings() async {
    final box = await _box;
    return box.get(_settingsKey) ?? ExportPdfSettings();
  }

  Future<void> saveSettings(ExportPdfSettings settings) async {
    final box = await _box;
    await box.put(_settingsKey, settings);
  }

  Future<ExportPdfSettings> getSettingsForRace() async {
    final settings = await getSettings();
    return settings;
  }

  Future<void> saveSettingsForRace(ExportPdfSettings settings) async {
    await saveSettings(settings);
  }
}
