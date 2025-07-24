import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/services/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../generated/l10n.dart';
import '../models/character_model.dart';
import '../models/note_model.dart';
import '../models/race_model.dart';
import '../models/template_model.dart';
import 'file_picker_service.dart';
import 'notification_service.dart';

abstract class BackupService {
  Future<void> exportData();
  Future<void> importData();
}

class BackupHelper {
  static const Map<String, Type> _boxTypes = {
    'characters': Character,
    'notes': Note,
    'races': Race,
    'templates': QuestionnaireTemplate,
    'folders': Folder,
  };

  static Future<Map<String, dynamic>> getBackupData() async {
    final characters = await HiveService.getBox<Character>('characters');
    final notes = await HiveService.getBox<Note>('notes');
    final races = await HiveService.getBox<Race>('races');
    final templates = await HiveService.getBox<QuestionnaireTemplate>('templates');
    final folders = await HiveService.getBox<Folder>('folders');


    return {
      'characters': characters.values.toList(),
      'notes': notes.values.toList(),
      'races': races.values.toList(),
      'templates': templates.values.toList(),
      'folders': folders.values.toList(),
    };
  }

  static bool validateBackupStructure(Map<String, dynamic> data) {
    return _boxTypes.keys.every(data.containsKey);
  }

  static Future<void> restoreFromBackupData(Map<String, dynamic> data) async {
    if (!validateBackupStructure(data)) {
      throw FormatException('Invalid backup structure');
    }

    try {
      final characters = await HiveService.getBox<Character>('characters');
      final notes = await HiveService.getBox<Note>('notes');
      final races = await HiveService.getBox<Race>('races');
      final templates = await HiveService.getBox<QuestionnaireTemplate>('templates');
      final folders = await HiveService.getBox<Folder>('folders');

      await characters.clear();
      await notes.clear();
      await races.clear();
      await templates.clear();
      await folders.clear();

      await _restoreToBox<Character>(characters, data['characters'] as List<dynamic>?);
      await _restoreToBox<Note>(notes, data['notes'] as List<dynamic>?);
      await _restoreToBox<Race>(races, data['races'] as List<dynamic>?);
      await _restoreToBox<QuestionnaireTemplate>(templates, data['templates'] as List<dynamic>?);
      await _restoreToBox<Folder>(folders, data['folders'] as List<dynamic>?);
    } catch (e) {
      debugPrint('Restore error: $e');
      rethrow;
    }
  }

  static Future<void> _restoreToBox<T>(Box<T> box, List<dynamic>? items) async {
    if (items == null || items.isEmpty) return;

    for (final json in items.cast<Map<String, dynamic>>()) {
      try {
        final item = _createModel(T, json);
        if (item != null) {
          await box.add(item as T);
        }
      } catch (e) {
        debugPrint('Error creating ${T.toString()} from json: $e\nJson: $json');
      }
    }
  }

  static dynamic _createModel(Type type, Map<String, dynamic> json) {
    switch (type) {
      case Character _:
        return Character.fromJson(json);
      case Note _:
        return Note.fromJson(json);
      case Race _:
        return Race.fromJson(json);
      case QuestionnaireTemplate _:
        return QuestionnaireTemplate.fromJson(json);
      case Folder _:
        return Folder.fromJson(json);
      default:
        return null;
    }
  }
}

class LocalBackupService implements BackupService {
  final FilePickerService filePickerService;
  final NotificationService notificationService;

  LocalBackupService({
    required this.filePickerService,
    required this.notificationService,
  });

  @override
  Future<void> exportData() async {
    try {
      final backupData = await BackupHelper.getBackupData();
      final hasData = backupData.values.any((list) => (list as List).isNotEmpty);

      if (!hasData) {
        notificationService.showError(S.current.error);
        return;
      }

      String backupJson;
      try {
        backupJson = await compute(_safeJsonEncode, backupData);
      } catch (e) {
        backupJson = jsonEncode(backupData);
      }

      if (kIsWeb) {
        await _exportForWeb(backupJson);
      } else {
        await _exportForMobile(backupJson);
      }

      notificationService.showSuccess(S.current.local_backup_success);
    } catch (e) {
      notificationService.showError('${S.current.local_backup_error}: $e');
      debugPrint('Export error: $e');
    }
  }

  Future<void> _exportForWeb(String backupJson) async {
    final bytes = utf8.encode(backupJson);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _exportForMobile(String backupJson) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'characterbook_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(utf8.encode(backupJson));
      
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: S.current.share_backup_file,
        subject: fileName,
      );
    } catch (e) {
      notificationService.showError('${S.current.local_backup_error}: $e');
    }
  }

  @override
  Future<void> importData() async {
    try {
      final jsonData = await filePickerService.pickRestoreFile();
      if (jsonData == null) {
        throw Exception('Invalid backup file');
      }

      await BackupHelper.restoreFromBackupData(jsonData);
      notificationService.showSuccess(S.current.local_restore_success);
    } catch (e, stack) {
      notificationService.showError('${S.current.local_restore_error}: $e');
      debugPrint('Restore failed: $e\n$stack');
    }
  }

  String _safeJsonEncode(dynamic data) => jsonEncode(data);
}

class CloudBackupService implements BackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  static const String _backupPrefix = 'characterbook_backup';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  final NotificationService notificationService;
  drive.DriveApi? _driveApi;
  bool isProcessing = false;

  CloudBackupService({required this.notificationService});

  @override
  Future<void> exportData() async {
    try {
      isProcessing = true;
      final backupData = await BackupHelper.getBackupData();
      final backupJson = jsonEncode(backupData);
      
      await _exportToGoogleDrive(backupJson);
      notificationService.showSuccess(S.current.cloud_backup_full_success);
    } catch (e) {
      notificationService.showError('${S.current.cloud_backup_error}: $e');
    } finally {
      isProcessing = false;
    }
  }

  @override
  Future<void> importData() async {
    try {
      isProcessing = true;
      final jsonStr = await _importFromGoogleDrive();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      await BackupHelper.restoreFromBackupData(data);

      final counts = {
        for (final entry in BackupHelper._boxTypes.entries)
          entry.key: (data[entry.key] as List?)?.length ?? 0,
      };

      notificationService.showSuccess(
        S.current.cloud_restore_success(
          counts['characters'].toString(),
          counts['notes'].toString(),
          counts['races'].toString(),
          counts['templates'].toString(),
          counts['folders'].toString(),
        ),
      );
    } catch (e) {
      notificationService.showError('${S.current.cloud_restore_error}: $e');
    } finally {
      isProcessing = false;
    }
  }

  Future<void> _exportToGoogleDrive(String jsonStr) async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signIn();
    if (account == null) throw Exception(S.current.auth_cancelled);

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception(S.current.auth_client_error);

    final driveApi = drive.DriveApi(client);
    final fileName = '${_backupPrefix}_${DateTime.now().toIso8601String()}.json';

    await driveApi.files.create(
      drive.File()..name = fileName,
      uploadMedia: drive.Media(
        Stream.value(utf8.encode(jsonStr)), 
        utf8.encode(jsonStr).length,
      ),
    );
  }

  Future<String> _importFromGoogleDrive() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception(S.current.auth_cancelled);

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception(S.current.auth_client_error);

    _driveApi ??= drive.DriveApi(client);

    final files = await _driveApi!.files.list(
      q: "name contains '$_backupPrefix' and mimeType='application/json'",
      orderBy: 'createdTime desc',
      pageSize: 1,
    );

    if (files.files == null || files.files!.isEmpty) {
      throw Exception(S.current.cloud_backup_not_found);
    }

    final file = files.files!.first;
    final response = await _driveApi!.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await _readStream(response.stream);
    return utf8.decode(bytes);
  }

  Future<Uint8List> _readStream(Stream<List<int>> stream) async {
    final bytesBuilder = BytesBuilder();
    await for (final chunk in stream) {
      bytesBuilder.add(chunk);
    }
    return bytesBuilder.toBytes();
  }
}