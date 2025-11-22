import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

enum WindowAction { minimize, toggleMaximize, close }

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        WindowControlButton(
          icon: Icons.minimize,
          action: WindowAction.minimize,
        ),
        WindowControlButton(
          icon: Icons.crop_square,
          action: WindowAction.toggleMaximize,
        ),
        WindowControlButton(
          icon: Icons.close,
          action: WindowAction.close,
          isClose: true,
        ),
      ],
    );
  }
}

class WindowControlButton extends StatefulWidget {
  const WindowControlButton({
    super.key,
    required this.icon,
    required this.action,
    this.isClose = false,
  });

  final IconData icon;
  final WindowAction action;
  final bool isClose;

  @override
  State<WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<WindowControlButton> {
  bool _isHovered = false;

  Future<void> _handleAction() async {
    try {
      switch (widget.action) {
        case WindowAction.minimize:
          await windowManager.minimize();
          break;
        case WindowAction.toggleMaximize:
          final isMaximized = await windowManager.isMaximized();
          if (isMaximized) {
            await windowManager.unmaximize();
          } else {
            await windowManager.maximize();
          }
          break;
        case WindowAction.close:
          await windowManager.close();
          break;
      }
    } catch (error) {
      debugPrint('Window action error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = _getBackgroundColor(colorScheme, isDark);
    final iconColor = _getIconColor(colorScheme);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleAction,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme, bool isDark) {
    if (!_isHovered) {
      return widget.isClose
          ? colorScheme.error.withOpacity(isDark ? 0.12 : 0.08)
          : colorScheme.onPrimaryContainer.withOpacity(isDark ? 0.08 : 0.04);
    }

    return widget.isClose
        ? colorScheme.error.withOpacity(isDark ? 0.24 : 0.16)
        : colorScheme.onSurface.withOpacity(isDark ? 0.16 : 0.12);
  }

  Color _getIconColor(ColorScheme colorScheme) {
    return widget.isClose
        ? colorScheme.error
        : _isHovered
            ? colorScheme.onSurface
            : colorScheme.onSurface.withOpacity(0.8);
  }
}
