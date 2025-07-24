import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/services/folder_service.dart';
import 'package:characterbook/ui/widgets/mixins/tag_mixin.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
class TagFilter extends StatelessWidget with TagMixin {
  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final BuildContext context;
  final bool showAllOption;
  final bool isForCharacters;

  const TagFilter({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    required this.context,
    this.showAllOption = true,
    this.isForCharacters = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final folderService = FolderService(Hive.box<Folder>('folders'));
    
    final standardTags = isForCharacters 
        ? [
            s.male, s.female, s.another,
            s.children, s.young, s.adults, s.elderly,
            s.short_name,
            s.a_to_z, s.z_to_a, s.age_asc, s.age_desc
          ]
        : [];

    final folderTags = generateFolderTags(context);
    final regularTags = tags.where((tag) => !isFolderTag(tag)).toList();

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          if (showAllOption)
            FilterChip(
              label: Text(s.all),
              selected: selectedTag == null,
              onSelected: (_) => onTagSelected(null),
              shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
              showCheckmark: false,
              selectedColor: theme.colorScheme.secondaryContainer,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: selectedTag == null
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ...folderTags.map((folderTag) {
            final folderName = getFolderNameFromTag(folderTag);
            final folderId = getFolderIdFromTag(folderTag);
            final folder = folderService.getFolderById(folderId);
            final folderColor = folder?.color ?? theme.colorScheme.primary;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                avatar: Icon(Icons.folder, size: 20, color: folderColor),
                label: Text(folderName),
                selected: selectedTag == folderTag,
                onSelected: (selected) => onTagSelected(selected ? folderTag : null),
                shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
                showCheckmark: false,
                selectedColor: folderColor,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: selectedTag == folderTag
                      ? folderColor
                      : theme.colorScheme.onSurface,
                ),
              ),
            );
          }),
          ...regularTags.map((tag) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(tag),
              selected: selectedTag == tag,
              onSelected: (selected) => onTagSelected(selected ? tag : null),
              shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
              showCheckmark: false,
              selectedColor: theme.colorScheme.secondaryContainer,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: selectedTag == tag
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          )),
          ...standardTags.map((tag) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(tag),
              selected: selectedTag == tag,
              onSelected: (selected) => onTagSelected(selected ? tag : null),
              shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline)),
              showCheckmark: false,
              selectedColor: theme.colorScheme.tertiaryContainer,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: selectedTag == tag
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          )),
        ],
      ),
    );
  }
}