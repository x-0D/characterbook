import 'dart:async';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/services/pdf_export_serivce.dart';
import 'package:characterbook/services/file_share_service.dart';
import 'package:characterbook/ui/dialogs/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/models/race_model.dart';

class RaceService {
  static const String _boxName = 'races';

  final Race? race;

  RaceService.forDatabase() : race = null;

  RaceService.forExport(this.race);

  Future<Box<Race>> get _box => Hive.openBox<Race>(_boxName);

  Future<int?> saveRace(Race race, {int? key}) async {
    final box = Hive.box<Race>('races');
    if (key != null) {
      await box.put(key, race);
      return key;
    } else {
      return await box.add(race);
    }
  }

  Future<List<Race>> getAllRaces() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<Race?> getRaceById(String id) async {
    final box = await _box;
    return box.values.firstWhere(
      (race) => race.id == id,
      orElse: () => Race.empty(),
    );
  }

  Future<List<Race>> getRacesByName(String name) async {
    final box = await _box;
    return box.values
        .where((race) => race.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<List<Race>> getRacesByTags(List<String> tags) async {
    final box = await _box;
    return box.values
        .where((race) => race.tags.any((tag) => tags.contains(tag)))
        .toList();
  }

  Future<List<Race>> getRacesByFolderId(String folderId) async {
    final box = await _box;
    return box.values.where((race) => race.folderId == folderId).toList();
  }

  Future<List<Race>> getRacesWithoutFolder() async {
    final box = await _box;
    return box.values
        .where((race) => race.folderId == null || race.folderId!.isEmpty)
        .toList();
  }

  Future<void> deleteRace(int key) async {
    final box = await _box;
    await box.delete(key);
  }

  Future<void> deleteRaceById(String id) async {
    final box = await _box;
    final raceKey = _getKeyForRaceId(box, id);
    if (raceKey != null) {
      await box.delete(raceKey);
    }
  }

  Future<void> updateRaceLogo(int key, Uint8List? logoBytes) async {
    final box = await _box;
    final race = box.get(key);
    if (race != null) {
      race.logo = logoBytes;
      await race.save();
    }
  }

  Future<void> updateRaceTags(int key, List<String> tags) async {
    final box = await _box;
    final race = box.get(key);
    if (race != null) {
      race.tags = tags;
      await race.save();
    }
  }

  Future<void> updateRaceFolder(int key, String? folderId) async {
    final box = await _box;
    final race = box.get(key);
    if (race != null) {
      race.folderId = folderId;
      await race.save();
    }
  }

  Future<int> getRacesCount() async {
    final box = await _box;
    return box.length;
  }

  Future<int> getRacesCountInFolder(String folderId) async {
    final box = await _box;
    return box.values.where((race) => race.folderId == folderId).length;
  }

  Future<List<Race>> searchRaces(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();

    return box.values
        .where((race) =>
            race.name.toLowerCase().contains(lowerQuery) ||
            race.description.toLowerCase().contains(lowerQuery) ||
            race.biology.toLowerCase().contains(lowerQuery) ||
            race.backstory.toLowerCase().contains(lowerQuery) ||
            race.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  Future<Set<String>> getAllUniqueTags() async {
    final box = await _box;
    final allTags = <String>{};

    for (final race in box.values) {
      allTags.addAll(race.tags);
    }

    return allTags;
  }

  Future<Map<String, int>> getPopularTags({int limit = 10}) async {
    final box = await _box;
    final tagCounts = <String, int>{};

    for (final race in box.values) {
      for (final tag in race.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.take(limit),
    );
  }

  Future<Map<String, dynamic>> exportRaceToJson(int key) async {
    final box = await _box;
    final race = box.get(key);

    if (race == null) {
      throw Exception('Раса с ключом $key не найдена');
    }

    return race.toJson();
  }

  Future<int> importRaceFromJson(Map<String, dynamic> json) async {
    final race = Race.fromJson(json);
    return await saveRace(race) ?? -1;
  }

  Future<List<int>> importRacesFromJsonList(
      List<Map<String, dynamic>> jsonList) async {
    final results = <int>[];

    for (final json in jsonList) {
      try {
        final race = Race.fromJson(json);
        final key = await saveRace(race);
        if (key != null) {
          results.add(key);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка импорта расы: $e');
        }
      }
    }

    return results;
  }

  Future<void> clearAllRaces() async {
    final box = await _box;
    await box.clear();
  }

  int? _getKeyForRaceId(Box<Race> box, String id) {
    for (var i = 0; i < box.length; i++) {
      final key = box.keyAt(i);
      final race = box.get(key);
      if (race != null && race.id == id) {
        return key;
      }
    }
    return null;
  }

  Future<List<Race>> getRacesPaginated({
    int page = 1,
    int pageSize = 20,
    String? folderId,
    List<String>? tags,
  }) async {
    final box = await _box;
    List<Race> filteredRaces;

    if (folderId != null) {
      filteredRaces =
          box.values.where((race) => race.folderId == folderId).toList();
    } else if (tags != null && tags.isNotEmpty) {
      filteredRaces = box.values
          .where((race) => race.tags.any((tag) => tags.contains(tag)))
          .toList();
    } else {
      filteredRaces = box.values.toList();
    }

    filteredRaces.sort((a, b) => a.name.compareTo(b.name));

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filteredRaces.length) {
      return [];
    }

    final endIndex = startIndex + pageSize;
    return filteredRaces.sublist(
      startIndex,
      endIndex > filteredRaces.length ? filteredRaces.length : endIndex,
    );
  }

  Future<bool> doesRaceExist(String name, {String? excludeId}) async {
    final box = await _box;
    return box.values.any((race) =>
        race.name == name && (excludeId == null || race.id != excludeId));
  }

  Future<Map<String, dynamic>> getRacesStatistics() async {
    final box = await _box;
    final races = box.values.toList();

    return {
      'totalRaces': races.length,
      'racesWithLogo': races.where((race) => race.logo != null).length,
      'racesWithFolder': races
          .where((race) => race.folderId != null && race.folderId!.isNotEmpty)
          .length,
      'racesWithTags': races.where((race) => race.tags.isNotEmpty).length,
      'averageTagsPerRace': races.isEmpty
          ? 0
          : races.fold(0,
                  (sum, race) => int.parse(sum.toString()) + race.tags.length) /
              races.length,
      'mostCommonTag': _getMostCommonTag(races),
    };
  }

  String? _getMostCommonTag(List<Race> races) {
    final tagCounts = <String, int>{};

    for (final race in races) {
      for (final tag in race.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    if (tagCounts.isEmpty) return null;

    return tagCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> exportToPdf(BuildContext context) async {
    bool isLoadingVisible = false;

    if (race == null) {
      throw Exception("Race is not set for export");
    }

    try {
      isLoadingVisible = true;
      _showLoadingDialogSafe(context, S.of(context).creating_pdf);

      final bytes = await _generatePdfWithTimeout();

      _hideLoadingDialogSafe(context);
      isLoadingVisible = false;

      await Future.delayed(const Duration(milliseconds: 100));
      await FileShareService.shareFile(
        bytes,
        '${race!.name}.pdf',
        text: 'Описание расы ${race!.name}',
        subject: 'PDF с описанием расы',
      );
    } catch (e) {
      if (isLoadingVisible) {
        _hideLoadingDialogSafe(context);
      }
      _showErrorDialog(context, 'Ошибка экспорта в PDF: ${e.toString()}');
    }
  }

  void _showLoadingDialogSafe(BuildContext context, String message) {
    if (context.mounted) {
      showLoadingDialog(context: context, message: message);
    }
  }

  void _hideLoadingDialogSafe(BuildContext context) {
    if (context.mounted) {
      hideLoadingDialog(context);
    }
  }

  Future<Uint8List> _generatePdfWithTimeout() async {
    try {
      final pdfService = await PdfExportService.createForRace(race!);
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
}
