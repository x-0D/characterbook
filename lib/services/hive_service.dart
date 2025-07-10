import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/custom_field_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final Map<String, Type> _openBoxTypes = {};
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
  }

  static Future<Box<T>> getBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      if (_openBoxTypes[name] == T) {
        return Hive.box(name) as Box<T>;
      }
      throw HiveError('The box "$name" is already open with different type');
    }
    
    final box = await Hive.openBox<T>(name);
    _openBoxTypes[name] = T;
    return box;
  }

  static Future<void> closeBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
      _openBoxTypes.remove(name);
    }
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
    _openBoxTypes.clear();
  }
}