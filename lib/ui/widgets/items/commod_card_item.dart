import 'package:flutter/material.dart';
import 'package:characterbook/generated/l10n.dart';

class CommonCardItem extends StatelessWidget {
  final String id;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? deleteConfirmationMessage;
  final EdgeInsetsGeometry margin;
  final double? elevation;
  final Color? selectedColor;
  final Color? defaultColor;
  final ShapeBorder? shape;
  final Widget child;

  const CommonCardItem({
    super.key,
    required this.id,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.deleteConfirmationMessage,
    this.margin = const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
    this.elevation,
    this.selectedColor,
    this.defaultColor,
    this.shape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    final hasEdit = onEdit != null;
    final hasDelete = onDelete != null;
    final canDismiss = hasEdit || hasDelete;

    DismissDirection dismissDirection = DismissDirection.none;
    if (hasEdit && hasDelete) {
      dismissDirection = DismissDirection.horizontal;
    } else if (hasEdit) {
      dismissDirection = DismissDirection.startToEnd;
    } else if (hasDelete) {
      dismissDirection = DismissDirection.endToStart;
    }

    Widget card = Card(
      margin: margin,
      elevation: elevation ?? (isSelected ? 2.0 : 1.0),
      color: _resolveBackgroundColor(colorScheme),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );

    if (canDismiss) {
      card = Dismissible(
        key: Key('common_card_$id'),
        direction: dismissDirection,
        background: hasEdit
            ? _buildSwipeBackground(
                context,
                alignment: Alignment.centerLeft,
                icon: Icons.edit_rounded,
                color: colorScheme.tertiaryContainer,
                label: s.edit,
              )
            : null,
        secondaryBackground: hasDelete
            ? _buildSwipeBackground(
                context,
                alignment: Alignment.centerRight,
                icon: Icons.delete_rounded,
                color: colorScheme.errorContainer,
                label: s.delete,
              )
            : null,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd && hasEdit) {
            onEdit!();
            return false;
          } else if (direction == DismissDirection.endToStart && hasDelete) {
            return await _showDeleteConfirmation(context);
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart && hasDelete) {
            onDelete!();
          }
        },
        child: card,
      );
    }

    return card;
  }

  Color _resolveBackgroundColor(ColorScheme colorScheme) {
    if (isSelected) {
      return selectedColor ?? colorScheme.secondaryContainer;
    }
    return defaultColor ?? colorScheme.surfaceContainerHigh;
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context).colorScheme.onTertiaryContainer),
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
    final s = S.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(s.delete),
            content: Text(deleteConfirmationMessage ?? s.deleteConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(s.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(s.delete),
              ),
            ],
          ),
        ) ??
        false;
  }
}
