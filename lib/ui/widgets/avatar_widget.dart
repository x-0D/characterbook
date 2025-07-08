import 'dart:typed_data';

import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final double size;
  final IconData defaultIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const AvatarWidget({
    super.key,
    this.imageBytes,
    required this.size,
    this.defaultIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  factory AvatarWidget.character({
    Key? key,
    required Uint8List? imageBytes,
    required double size,
  }) {
    return AvatarWidget(
      key: key,
      imageBytes: imageBytes,
      size: size,
      defaultIcon: Icons.person,
    );
  }

  factory AvatarWidget.race({
    Key? key,
    required Uint8List? imageBytes,
    double size = 24,
  }) {
    return AvatarWidget(
      key: key,
      imageBytes: imageBytes,
      size: size,
      defaultIcon: Icons.emoji_people,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final iconClr = iconColor ?? theme.colorScheme.onSurfaceVariant;

    return imageBytes != null
        ? CircleAvatar(
            backgroundImage: MemoryImage(imageBytes!),
            radius: size,
          )
        : CircleAvatar(
            radius: size,
            backgroundColor: bgColor,
            child: Icon(
              defaultIcon,
              size: size * (defaultIcon == Icons.person ? 0.7 : 1.0),
              color: iconClr,
            ),
          );
  }
}