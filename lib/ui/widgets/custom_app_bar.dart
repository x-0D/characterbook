import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../pages/settings_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController? searchController;
  final VoidCallback onSearchToggle;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? additionalActions;
  final VoidCallback? onTemplatesPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    this.searchController,
    required this.onSearchToggle,
    this.searchHint,
    this.onSearchChanged,
    this.additionalActions,
    this.onTemplatesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    final List<Widget> baseActions = [
      if (!isSearching && onTemplatesPressed != null)
        IconButton(
          icon: const Icon(Icons.library_books_outlined),
          onPressed: onTemplatesPressed,
          tooltip: s.templates,
        ),
      IconButton(
        icon: Icon(isSearching ? Icons.close : Icons.search),
        onPressed: onSearchToggle,
        tooltip: s.search,
      ),
    ];

    final additional = additionalActions ?? [];
    
    final settingsAction = IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ),
      tooltip: s.settings,
    );

    final bool needToHideActions = additional.length > 3;

    final List<Widget> visibleActions = [
      ...baseActions,
      if (!needToHideActions) ...additional,
      if (needToHideActions) ...additional.take(3),
      settingsAction,
    ];

    final List<PopupMenuEntry<Widget>> hiddenMenuItems = needToHideActions
        ? additional.skip(3).map((action) {
            return PopupMenuItem<Widget>(
              child: _getActionWidget(action),
              onTap: () => _triggerAction(action),
            );
          }).toList()
        : [];

    return AppBar(
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: searchHint ?? s.search_hint,
                border: InputBorder.none,
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              style: textTheme.bodyLarge,
              onChanged: onSearchChanged,
            )
          : Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
      centerTitle: true,
      actions: [
        baseActions.last,
        
        if (!isSearching && onTemplatesPressed != null) baseActions.first,
        
        if (!needToHideActions) ...additional,
        if (needToHideActions) ...additional.take(3),

        if (hiddenMenuItems.isNotEmpty)
          PopupMenuButton<Widget>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => hiddenMenuItems,
          ),
        
        settingsAction,
      ],
    );
  }

  Widget _getActionWidget(Widget action) {
    if (action is IconButton) {
      return ListTile(
        leading: action.icon,
        title: Text(action.tooltip ?? ''),
      );
    } else if (action is ActionChip) {
      return ListTile(
        leading: action.avatar,
        title: Text(action.label?.toString() ?? ''),
      );
    }
    return action;
  }

  void _triggerAction(Widget action) {
    if (action is IconButton) {
      action.onPressed?.call();
    } else if (action is ActionChip) {
      action.onPressed?.call();
    } else if (action is GestureDetector && action.onTap != null) {
      action.onTap?.call();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}