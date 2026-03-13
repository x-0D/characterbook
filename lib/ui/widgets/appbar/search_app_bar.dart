import 'package:flutter/material.dart';
import 'package:characterbook/generated/l10n.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double toolbarHeight;
  final BorderRadiusGeometry? bottomBorderRadius;
  final Widget? leading;

  final List<String> suggestions;

  final ValueChanged<String> onSubmitted;

  final ValueChanged<String>? onChanged;

  const SearchAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.toolbarHeight = 64,
    this.bottomBorderRadius,
    this.leading,
    required this.suggestions,
    required this.onSubmitted,
    this.onChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: _buildSearchBar(context),
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      leading: leading,
      actions: actions,
      shape: ContinuousRectangleBorder(
        borderRadius: bottomBorderRadius ?? BorderRadius.zero,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return SizedBox(
      height: 48,
      child: SearchBar(
        hintText: s.search,
        leading: const Icon(Icons.search_rounded),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHigh,
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        overlayColor: WidgetStatePropertyAll(
          colorScheme.primary.withOpacity(0.08),
        ),
        onTap: () => _openSearchView(context),
        enabled: false,
      ),
    );
  }


  void _openSearchView(BuildContext context) {
    showSearch(
      context: context,
      delegate: MaterialSearchDelegate(
        suggestions: suggestions,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }
}

class MaterialSearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;

  MaterialSearchDelegate({
    required this.suggestions,
    required this.onSubmitted,
    this.onChanged,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSubmitted(query);
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onChanged?.call(query);

    final filtered = suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filtered[index]),
          onTap: () {
            query = filtered[index];
            showResults(context);
          },
        );
      },
    );
  }
}
