import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        shape: StadiumBorder(
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        showCheckmark: false,
        side: BorderSide.none,
        selectedColor: theme.colorScheme.secondaryContainer,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: selected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}