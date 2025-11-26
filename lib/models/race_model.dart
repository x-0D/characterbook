// race_model.dart
import 'package:characterbook/models/settings/exportable_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'race_model.g.dart';

@HiveType(typeId: 3)
class Race extends HiveObject implements ExportableModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String biology;

  @HiveField(4)
  String backstory;

  @HiveField(5)
  Uint8List? logo;

  @HiveField(6, defaultValue: null)
  String? folderId;

  @HiveField(7, defaultValue: const [])
  List<String> tags;

  @HiveField(8, defaultValue: const [])
  List<Uint8List> additionalImages;

  @HiveField(9)
  DateTime lastEdited;

  Race({
    String? id,
    required this.name,
    this.description = '',
    this.biology = '',
    this.backstory = '',
    this.logo,
    this.folderId,
    List<String> tags = const [],
    List<Uint8List> additionalImages = const [],
    DateTime? lastEdited,
  })  : id = id ?? '',
        tags = List.from(tags),
        additionalImages = List.from(additionalImages),
        lastEdited = lastEdited ?? DateTime.now();

  factory Race.empty() => Race(id: '', name: '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Race &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          biology == other.biology &&
          backstory == other.backstory &&
          folderId == other.folderId &&
          listEquals(tags, other.tags) &&
          listEquals(additionalImages, other.additionalImages) &&
          lastEdited == other.lastEdited;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        biology,
        backstory,
        folderId,
        Object.hashAll(tags),
        Object.hashAll(additionalImages),
        lastEdited,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'biology': biology,
      'backstory': backstory,
      'logo': logo?.toList(),
      'folderId': folderId,
      'tags': tags,
      'additionalImages': additionalImages.map((e) => e.toList()).toList(),
      'lastEdited': lastEdited.toIso8601String(),
    };
  }

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      biology: json['biology'] ?? '',
      backstory: json['backstory'] ?? '',
      logo: json['logo'] != null
          ? Uint8List.fromList(List<int>.from(json['logo']))
          : null,
      folderId: json['folderId'],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      additionalImages: (json['additionalImages'] as List?)
              ?.map((e) => Uint8List.fromList(List<int>.from(e)))
              .toList() ??
          [],
      lastEdited: json['lastEdited'] != null
          ? DateTime.parse(json['lastEdited'])
          : DateTime.now(),
    );
  }

  Race copyWith({
    String? id,
    String? name,
    String? description,
    String? biology,
    String? backstory,
    Uint8List? logo,
    String? folderId,
    List<String>? tags,
    List<Uint8List>? additionalImages,
    DateTime? lastEdited,
  }) {
    return Race(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      biology: biology ?? this.biology,
      backstory: backstory ?? this.backstory,
      logo: logo ?? this.logo,
      folderId: folderId ?? this.folderId,
      tags: tags ?? List.from(this.tags),
      additionalImages: additionalImages ?? List.from(this.additionalImages),
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }

  @override
  Uint8List? get mainImage => logo;

  @override
  Map<String, dynamic> toExportMap() {
    return {
      'type': 'race',
      'id': id,
      'name': name,
      'description': description,
      'mainImage': logo,
      'additionalImages': additionalImages,
      'tags': tags,
      'lastEdited': lastEdited,
      'details': {
        'biology': biology,
        'backstory': backstory,
        'description': description,
      }
    };
  }

  @override
  String get modelType => 'race';
}
