import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/sections/settings_section.dart';
import 'package:flutter/material.dart';

class AcknowledgementsSection extends StatelessWidget {
  const AcknowledgementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingsSection(
      title: s.acknowledgements,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildContributorChip(context, 'Данила Ганьков'),
                    _buildContributorChip(context, 'Makoto🐼'),
                    _buildContributorChip(context, 'Максим Семенков'),
                    _buildContributorChip(context, 'Артём Голубев'),
                    _buildContributorChip(context, 'Евгений Стратий'),
                    _buildContributorChip(context, 'Никита Жевнерович'),
                    _buildContributorChip(context, 'KellSmiley'),
                    _buildContributorChip(context, 'Участники EnA'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContributorChip(BuildContext context, String name) {
    final theme = Theme.of(context);
    
    return Chip(
      label: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      visualDensity: VisualDensity.compact,
    );
  }
}