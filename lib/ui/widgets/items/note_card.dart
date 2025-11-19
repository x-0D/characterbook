import 'dart:math';

import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/services/folder_service.dart';
import 'package:characterbook/ui/widgets/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:characterbook/models/characters/character_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enableDrag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.isSelected = false,
    required this.onTap,
    this.enableDrag = false,
    required this.onEdit,
    required this.onDelete,
  });

  void _showNoteContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.note(
        note: note,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);
    final random = Random(note.title.hashCode + note.content.hashCode);
    
    final characterBox = Hive.box<Character>('characters');
    final characters = note.characterIds
        .map((id) => characterBox.get(id))
        .whereType<Character>()
        .toList();
    final folder = note.folderId != null 
        ? FolderService(Hive.box<Folder>('folders')).getFolderById(note.folderId!)
        : null;

    final borderRadius = 16.0 + random.nextInt(8);
    final elevation = isSelected ? 3.0 : 1.0;
    final colorVariation = random.nextDouble() * 0.1;

    final backgroundColor = folder?.color.withOpacity(0.1) ?? 
        (isSelected 
            ? colorScheme.secondaryContainer.withOpacity(0.8 + colorVariation)
            : colorScheme.surfaceContainerHigh.withOpacity(0.9 + colorVariation));

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        icon: Icons.edit_rounded,
        color: colorScheme.tertiaryContainer,
        label: s.edit,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        icon: Icons.delete_rounded,
        color: colorScheme.errorContainer,
        label: s.delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        elevation: elevation,
        color: backgroundColor,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: isSelected
              ? BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          onLongPress: () => _showNoteContextMenu(context),
          child: Padding(
            padding: EdgeInsets.all(12 + random.nextInt(4).toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_rounded,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (note.content.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () => _showNoteContextMenu(context),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (folder != null || note.tags.isNotEmpty || characters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (folder != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: folder.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular((12 + random.nextInt(4)).toDouble()),
                              border: Border.all(
                                color: folder.color.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_rounded, 
                                  size: 16, 
                                  color: folder.color),
                                const SizedBox(width: 6),
                                Text(
                                  folder.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: folder.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...characters.map((character) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular((12 + random.nextInt(4)).toDouble()),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded,
                                size: 16,
                                color: colorScheme.onPrimaryContainer),
                              const SizedBox(width: 6),
                              Text(
                                character.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )),
                        ...note.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular((12 + random.nextInt(4)).toDouble()),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete),
        content: Text(S.of(context).delete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    ) ?? false;
  }
}