import 'package:flutter/material.dart';
import 'window_controls.dart';

class DesktopTitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AppTitle(),
          const Positioned(
            right: 0,
            child: WindowControls(),
          ),
        ],
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AppIcon(),
        const SizedBox(width: 8),
        Text(
          'CharacterBook',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipOval(
      child: Container(
        width: 24,
        height: 24,
        color: theme.colorScheme.surfaceContainerHigh,
        child: Image.asset(
          'assets/iconapp.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.book,
              size: 16,
              color: theme.colorScheme.primary,
            );
          },
        ),
      ),
    );
  }
}
