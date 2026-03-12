import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/default_templates.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TemplateRepository {
  Future<List<QuestionnaireTemplate>> getAll();
  Future<void> save(QuestionnaireTemplate template, {String? name});
  Future<void> delete(String name);
  Future<void> initializeDefaultTemplates();
}

class TemplateRepositoryHive implements TemplateRepository {
  final Box<QuestionnaireTemplate> _box;

  TemplateRepositoryHive(this._box);

  @override
  Future<List<QuestionnaireTemplate>> getAll() async => _box.values.toList();

  @override
  Future<void> save(QuestionnaireTemplate template, {String? name}) async {
    await _box.put(name ?? template.name, template);
  }

  @override
  Future<void> delete(String name) async => _box.delete(name);

  @override
  Future<void> initializeDefaultTemplates() async {
    if (_box.isNotEmpty) return;
    final defaultTemplates = getDefaultTemplates();
    for (final template in defaultTemplates) {
      await _box.put(template.name, template);
    }
  }
}
