import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppIcon(),
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

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

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
