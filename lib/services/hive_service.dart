import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/custom_field_model.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final Map<String, Box> _openBoxes = {};
  static bool _isInitialized = false;

  static Future<void> initHive() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _registerAdapters();
      _isInitialized = true;
    }
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(CharacterAdapter().typeId)) {
      Hive.registerAdapter(CharacterAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(RaceAdapter().typeId)) {
      Hive.registerAdapter(RaceAdapter());
    }
    if (!Hive.isAdapterRegistered(QuestionnaireTemplateAdapter().typeId)) {
      Hive.registerAdapter(QuestionnaireTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(CustomFieldAdapter().typeId)) {
      Hive.registerAdapter(CustomFieldAdapter());
    }
    if (!Hive.isAdapterRegistered(FolderAdapter().typeId)) {
      Hive.registerAdapter(FolderAdapter());
    }
    if (!Hive.isAdapterRegistered(FolderTypeAdapter().typeId)) {
      Hive.registerAdapter(FolderTypeAdapter());
    }
  }

  static Future<Box<T>> getBox<T>(String name) async {
    if (_openBoxes.containsKey(name)) {
      return _openBoxes[name]! as Box<T>;
    }
    
    final box = await Hive.openBox<T>(name);
    _openBoxes[name] = box;
    return box;
  }

  static Box<T>? getOpenBox<T>(String name) {
    return _openBoxes.containsKey(name) ? _openBoxes[name]! as Box<T> : null;
  }

  static Future<void> closeBox(String name) async {
    if (_openBoxes.containsKey(name)) {
      await _openBoxes[name]!.close();
      _openBoxes.remove(name);
    }
  }

  static Future<void> closeBoxes() async {
    await Future.wait(_openBoxes.values.map((box) => box.close()));
    _openBoxes.clear();
  }
}