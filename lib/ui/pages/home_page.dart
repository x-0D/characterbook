import 'package:characterbook/ui/pages/random_number_page.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import 'characters/character_list_page.dart';
import 'notes/note_list_page.dart';
import 'races/race_list_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<Widget> _pages = [
    HomeScreen(),
    CharacterListPage(),
    RaceListPage(),
    NotesListPage(),
    SearchPage(),
    SettingsPage(),
    RandomNumberPage(),
  ];

  static const List<IconData> _pageIcons = [
    Icons.home_outlined,
    Icons.people_alt_outlined,
    Icons.emoji_people_outlined,
    Icons.note_alt_outlined,
    Icons.search_outlined,
    Icons.settings_outlined,
    Icons.casino_outlined,
  ];

  static const List<IconData> _selectedPageIcons = [
    Icons.home,
    Icons.people_alt,
    Icons.emoji_people,
    Icons.note_alt,
    Icons.search,
    Icons.settings,
    Icons.casino,
  ];

  int _currentIndex = 0;
  static const bool _isExpanded = false;

  List<String> _getPageTitles(BuildContext context) => [
        'Home',
        S.of(context).characters,
        S.of(context).races,
        S.of(context).posts,
        S.of(context).search,
        S.of(context).settings,
        'D&D',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return _DesktopLayout(
                currentIndex: _currentIndex,
                pages: _pages,
                pageTitles: _getPageTitles(context),
                pageIcons: _pageIcons,
                selectedPageIcons: _selectedPageIcons,
                onIndexChanged: _updateIndex,
              );
            } else {
              return _MobileLayout(
                currentIndex: _currentIndex,
                pages: _pages,
                pageTitles: _getPageTitles(context),
                pageIcons: _pageIcons,
                selectedPageIcons: _selectedPageIcons,
                onIndexChanged: _updateIndex,
              );
            }
          },
        ),
      ),
    );
  }

  void _updateIndex(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.currentIndex,
    required this.pages,
    required this.pageTitles,
    required this.pageIcons,
    required this.selectedPageIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<Widget> pages;
  final List<String> pageTitles;
  final List<IconData> pageIcons;
  final List<IconData> selectedPageIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavigationRail(
          currentIndex: currentIndex,
          pageTitles: pageTitles,
          pageIcons: pageIcons,
          selectedPageIcons: selectedPageIcons,
          onIndexChanged: onIndexChanged,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pages[currentIndex],
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.currentIndex,
    required this.pages,
    required this.pageTitles,
    required this.pageIcons,
    required this.selectedPageIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<Widget> pages;
  final List<String> pageTitles;
  final List<IconData> pageIcons;
  final List<IconData> selectedPageIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pages[currentIndex],
          ),
        ),
        _BottomNavigation(
          currentIndex: currentIndex,
          pageTitles: pageTitles,
          pageIcons: pageIcons,
          selectedPageIcons: selectedPageIcons,
          onIndexChanged: onIndexChanged,
        ),
      ],
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({
    required this.currentIndex,
    required this.pageTitles,
    required this.pageIcons,
    required this.selectedPageIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<String> pageTitles;
  final List<IconData> pageIcons;
  final List<IconData> selectedPageIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: _HomePageState._isExpanded ? 200 : 80,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            pageTitles.length,
            (index) => _NavItem(
              icon: currentIndex == index 
                  ? selectedPageIcons[index] 
                  : pageIcons[index],
              label: pageTitles[index],
              isSelected: currentIndex == index,
              onTap: () => onIndexChanged(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.pageTitles,
    required this.pageIcons,
    required this.selectedPageIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<String> pageTitles;
  final List<IconData> pageIcons;
  final List<IconData> selectedPageIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              _HomeNavItem(
                isSelected: currentIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
              _OtherNavItems(
                currentIndex: currentIndex,
                pageTitles: pageTitles,
                pageIcons: pageIcons,
                selectedPageIcons: selectedPageIcons,
                onIndexChanged: onIndexChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _HomePageState._isExpanded 
                  ? MainAxisAlignment.start 
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (_HomePageState._isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  const _HomeNavItem({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.home : Icons.home_outlined,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Home',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtherNavItems extends StatelessWidget {
  const _OtherNavItems({
    required this.currentIndex,
    required this.pageTitles,
    required this.pageIcons,
    required this.selectedPageIcons,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final List<String> pageTitles;
  final List<IconData> pageIcons;
  final List<IconData> selectedPageIcons;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          _NavButton(
            index: 1,
            currentIndex: currentIndex,
            outlineIcon: Icons.people_alt_outlined,
            filledIcon: Icons.people_alt,
            label: pageTitles[1],
            onIndexChanged: onIndexChanged,
          ),
          _NavButton(
            index: 2,
            currentIndex: currentIndex,
            outlineIcon: Icons.emoji_people_outlined,
            filledIcon: Icons.emoji_people,
            label: pageTitles[2],
            onIndexChanged: onIndexChanged,
          ),
          _NavButton(
            index: 3,
            currentIndex: currentIndex,
            outlineIcon: Icons.note_alt_outlined,
            filledIcon: Icons.note_alt,
            label: pageTitles[3],
            onIndexChanged: onIndexChanged,
          ),
          _NavButton(
            index: 4,
            currentIndex: currentIndex,
            outlineIcon: Icons.search_outlined,
            filledIcon: Icons.search,
            label: pageTitles[4],
            onIndexChanged: onIndexChanged,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.index,
    required this.currentIndex,
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.onIndexChanged,
  });

  final int index;
  final int currentIndex;
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onIndexChanged(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}