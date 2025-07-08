import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

import '../../../../models/race_model.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const RaceCard({
    super.key,
    required this.race,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AvatarWidget.race(imageBytes: race.logo, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(race.name, style: textTheme.bodyLarge),
                    Text(
                      race.description.isNotEmpty ? race.description : 'No description',
                      style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                onPressed: onLongPress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}