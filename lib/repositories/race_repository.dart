import 'package:characterbook/models/race_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class RaceRepository {
  Future<List<Race>> getAll();
  Future<Race?> getById(String id);
  Future<Race?> getByKey(dynamic key);
  Future<dynamic> save(Race race, {dynamic key});
  Future<void> delete(dynamic key);
}

class RaceRepositoryHive implements RaceRepository {
  final Box<Race> _box;

  RaceRepositoryHive(this._box);

  @override
  Future<List<Race>> getAll() async => _box.values.toList();

  @override
  Future<Race?> getById(String id) async =>
      _box.values.firstWhere((r) => r.id == id);

  @override
  Future<Race?> getByKey(dynamic key) async => _box.get(key);

  @override
  Future<dynamic> save(Race race, {dynamic key}) async {
    if (key != null) {
      await _box.put(key, race);
      return key;
    } else {
      return await _box.add(race);
    }
  }

  @override
  Future<void> delete(dynamic key) async => _box.delete(key);
}
