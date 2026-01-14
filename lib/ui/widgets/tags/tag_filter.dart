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
    final colorScheme = theme.colorScheme;
    final s = S.of(context);
    final folderService = FolderService(Hive.box<Folder>('folders'));
    
    final standardTags = isForCharacters 
      ? [
          s.male, s.female, s.another,
          s.children, s.young, s.adults, s.elderly,
          s.a_to_z, s.z_to_a, s.age_asc, s.age_desc
        ]
      : [];

    final folderTags = generateFolderTags(context);
    final regularTags = tags.where((tag) => 
      !isFolderTag(tag) && 
      (!isForCharacters || !standardTags.contains(tag)))
    .toList();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (showAllOption)
            _buildExpressiveChip(
              context: context,
              label: s.all,
              isSelected: selectedTag == null,
              onSelected: (_) => onTagSelected(null),
              icon: null,
              color: colorScheme.secondaryContainer,
              
            ),
          ...folderTags.map((folderTag) {
            final folderName = getFolderNameFromTag(folderTag);
            final folderId = getFolderIdFromTag(folderTag);
            final folder = folderService.getFolderById(folderId);
            final folderColor = folder != null 
                ? Color(folder.colorValue) 
                : colorScheme.primary;
            
            return _buildExpressiveChip(
              context: context,
              label: folderName,
              isSelected: selectedTag == folderTag,
              onSelected: (selected) => onTagSelected(selected ? folderTag : null),
              icon: Icon(Icons.folder_rounded, size: 20, color: folderColor),
              color: folderColor.withOpacity(0.2),
              selectedTextColor: folderColor,
              
            );
          }),
          ...regularTags.map((tag) => _buildExpressiveChip(
            context: context,
            label: tag,
            isSelected: selectedTag == tag,
            onSelected: (selected) => onTagSelected(selected ? tag : null),
            icon: null,
            color: colorScheme.secondaryContainer,
            
          )),
          if (isForCharacters)
            ...standardTags.map((tag) => _buildExpressiveChip(
              context: context,
              label: tag,
              isSelected: selectedTag == tag,
              onSelected: (selected) => onTagSelected(selected ? tag : null),
              icon: null,
              color: colorScheme.tertiaryContainer,
              
            )),
        ],
      ),
    );
  }

  Widget _buildExpressiveChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required Color color,
    Widget? icon,
    Color? selectedTextColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = isSelected 
        ? (selectedTextColor ?? colorScheme.onSecondaryContainer)
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) 
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: icon,
                ),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: onSelected,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSelected ? 8 : 20),
            side: isSelected 
                ? BorderSide.none 
                : BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          showCheckmark: false,
          selectedColor: color,
          backgroundColor: colorScheme.surfaceContainerLow,
          elevation: isSelected ? 1 : 0,
          pressElevation: 1,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}