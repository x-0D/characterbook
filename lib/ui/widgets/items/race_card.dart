import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/services/folder_service.dart';
import 'package:characterbook/ui/pages/races/race_management_page.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  //final VoidCallback onMenuPressed;
  final bool enableDrag;

  const RaceCard({
    super.key,
    required this.race,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    //required this.onMenuPressed,
    this.enableDrag = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folder = race.folderId != null 
        ? FolderService(Hive.box<Folder>('folders')).getFolderById(race.folderId!)
        : null;

    final backgroundColor = folder?.color.withOpacity(0.1) ?? 
        (isSelected 
            ? theme.colorScheme.secondaryContainer 
            : theme.colorScheme.surfaceContainer);

    return Dismissible(
      key: Key(race.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        icon: Icons.edit_rounded,
        color: theme.colorScheme.tertiaryContainer,
        label: S.of(context).edit,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        icon: Icons.delete_rounded,
        color: theme.colorScheme.errorContainer,
        label: S.of(context).delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => RaceManagementPage(race: race),
            ),
          );
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      onDismissed: (direction) async {
        await Hive.box<Race>('characters').delete(race.key);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: enableDrag ? null : onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarWidget.race(imageBytes: race.logo, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(race.name, style: theme.textTheme.bodyLarge),
                          if (race.description.isNotEmpty)
                            Text(
                              race.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, 
                        color: theme.colorScheme.onSurfaceVariant),
                      onPressed: onLongPress,
                    ),
                  ],
                ),
                if (folder != null || race.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (folder != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: folder.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: folder.color.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder, 
                                  size: 16, 
                                  color: theme.colorScheme.onPrimaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  folder.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (folder != null && race.tags.isNotEmpty)
                          const SizedBox(width: 8),
                        ...race.tags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }),
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