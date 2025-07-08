import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import 'characters/character_list_page.dart';
import 'notes/note_list_page.dart';
import 'races/race_list_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CharacterListPage(),
    RaceListPage(),
    NotesListPage(),
    SearchPage(),
    SettingsPage(),
  ];

  final List<String> _pageTitles = [
    S.current.characters,
    S.current.races,
    S.current.posts,
    S.current.search,
    S.current.settings,
  ];

  final List<IconData> _pageIcons = [
    Icons.people_alt,
    Icons.emoji_people,
    Icons.note_alt,
    Icons.search,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawerEnableOpenDragGesture: true,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  "CharacterBook",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _pages.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(_pageIcons[index]),
                  title: Text(_pageTitles[index]),
                  selected: _currentIndex == index,
                  selectedColor: colorScheme.onPrimaryContainer,
                  selectedTileColor: colorScheme.primaryContainer,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _currentIndex < 4 ? _currentIndex : 0,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: Text(S.of(context).characters),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_people_outlined),
                  selectedIcon: Icon(Icons.emoji_people),
                  label: Text(S.of(context).races),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt),
                  label: Text(S.of(context).posts),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search_outlined),
                  label: Text(S.of(context).search),
                ),
              ],
            ),
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: !isLargeScreen && _currentIndex < 4
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: S.of(context).characters,
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_people_outlined),
                  selectedIcon: Icon(Icons.emoji_people),
                  label: S.of(context).races,
                ),
                NavigationDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt),
                  label: S.of(context).posts,
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search_outlined),
                  label: S.of(context).search,
                ),
              ],
            )
          : null,
    );
  }
}