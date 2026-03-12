import 'package:characterbook/models/note_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class NoteRepository {
  Future<List<Note>> getAll();
  Future<Note?> getById(dynamic key);
  Future<dynamic> save(Note note, {dynamic key});
  Future<void> delete(dynamic key);
  Future<List<Note>> getNotesForCharacter(String characterId);
}

class NoteRepositoryHive implements NoteRepository {
  final Box<Note> _box;

  NoteRepositoryHive(this._box);

  @override
  Future<List<Note>> getAll() async => _box.values.toList();

  @override
  Future<Note?> getById(dynamic key) async => _box.get(key);

  @override
  Future<dynamic> save(Note note, {dynamic key}) async {
    if (key != null) {
      await _box.put(key, note);
      return key;
    } else {
      return await _box.add(note);
    }
  }

  @override
  Future<void> delete(dynamic key) async => _box.delete(key);

  @override
  Future<List<Note>> getNotesForCharacter(String characterId) async =>
      _box.values
          .where((note) => note.characterIds.contains(characterId))
          .toList();
}
