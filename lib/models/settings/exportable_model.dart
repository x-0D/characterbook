import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'exportable_model.g.dart';

@HiveType(typeId: 12)
abstract class ExportableModel extends HiveObject {
  @HiveField(0)
  String get id;

  @HiveField(1)
  String get name;

  @HiveField(2)
  String get description;

  @HiveField(3)
  Uint8List? get mainImage;

  @HiveField(4)
  List<Uint8List> get additionalImages;

  @HiveField(5)
  List<String> get tags;

  @HiveField(6)
  DateTime get lastEdited;

  Map<String, dynamic> toExportMap();
  String get modelType;
}
