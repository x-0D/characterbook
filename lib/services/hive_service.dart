import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/custom_field_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static bool _isInitialized = false;
  static final Map<String, Type> _openBoxTypes = {};

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
  }

  static Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      if (_openBoxTypes[name] != T) {
        await Hive.box(name).close();
        _openBoxTypes.remove(name);
        return await _openNewBox<T>(name);
      }
      return Hive.box(name) as Box<T>;
    }
    return await _openNewBox<T>(name);
  }

  static Future<Box<T>> _openNewBox<T>(String name) async {
    final box = await Hive.openBox<T>(name);
    _openBoxTypes[name] = T;
    return box;
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
    _openBoxTypes.clear();
  }
}