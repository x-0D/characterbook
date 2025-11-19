import 'package:flutter/material.dart';
import 'package:characterbook/models/characters/character_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/services/character_service.dart';
import 'package:characterbook/services/race_service.dart';
import 'package:characterbook/ui/widgets/search_bar.dart';
import 'package:characterbook/ui/widgets/category_chip.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/pages/characters/character_management_page.dart';
import 'package:characterbook/ui/pages/races/race_management_page.dart';
import 'package:characterbook/ui/cards/character_modal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CharacterService _characterService = CharacterService.forDatabase();
  final RaceService _raceService = RaceService.forDatabase();
  
  List<Character> _characters = [];
  List<Race> _races = [];
  List<Character> _filteredCharacters = [];
  List<Race> _filteredRaces = [];
  String _searchQuery = '';
  HomeContentType _selectedContentType = HomeContentType.characters;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final characters = await _characterService.getAllCharacters();
    final races = await _raceService.getAllRaces();
    
    setState(() {
      _characters = characters;
      _races = races;
      _filteredCharacters = characters;
      _filteredRaces = races;
    });
  }

  void _filterContent(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      
      if (_selectedContentType == HomeContentType.characters) {
        _filteredCharacters = _characters.where((character) =>
          character.name.toLowerCase().contains(_searchQuery) ||
          (character.race?.name.toLowerCase().contains(_searchQuery) ?? false) ||
          character.tags.any((tag) => tag.toLowerCase().contains(_searchQuery))
        ).toList();
      } else {
        _filteredRaces = _races.where((race) =>
          race.name.toLowerCase().contains(_searchQuery) ||
          race.description.toLowerCase().contains(_searchQuery) ||
          race.tags.any((tag) => tag.toLowerCase().contains(_searchQuery))
        ).toList();
      }
    });
  }

  void _changeContentType(HomeContentType type) {
    setState(() {
      _selectedContentType = type;
      _filterContent(_searchQuery);
    });
  }

  int _getCharacterCountForRace(Race race) {
    return _characters.where((character) => character.race?.id == race.id).length;
  }

  Widget _buildCharacterKeepCard(Character character, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = character.imageBytes != null;

    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        color: hasImage ? Colors.transparent : colorScheme.surfaceContainerHigh,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showCharacterDetail(character),
          child: Container(
            height: 180,
            decoration: hasImage
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: MemoryImage(character.imageBytes!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.8),
                        colorScheme.secondaryContainer.withOpacity(0.6),
                      ],
                    ),
                  ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      if (character.race != null || character.age > 0)
                        Text(
                          [
                            if (character.race != null) character.race!.name,
                            if (character.age > 0) '${character.age} ${S.of(context).years}',
                          ].join(' • '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      
                      const Spacer(),
                      
                      if (character.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: character.tags.take(2).map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(character.lastEdited),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          onPressed: () => _showCharacterContextMenu(character),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRaceKeepCard(Race race, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final characterCount = _getCharacterCountForRace(race);

    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        color: colorScheme.surfaceContainerHigh,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editRace(race),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (race.logo != null)
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.memory(
                          race.logo!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                
                Text(
                  race.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                if (race.description.isNotEmpty)
                  Text(
                    race.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const Spacer(),
                
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$characterCount ${S.of(context).characters}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (race.tags.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          race.tags.first,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCharacterDetail(Character character) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CharacterModalCard(character: character),
    );
  }

  void _showCharacterContextMenu(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCharacterContextMenu(character),
    );
  }

  Widget _buildCharacterContextMenu(Character character) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit_rounded, color: colorScheme.onSurfaceVariant),
            title: Text(S.of(context).edit_character),
            onTap: () {
              Navigator.pop(context);
              _editCharacter(character);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: colorScheme.error),
            title: Text(
              S.of(context).delete_character,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _deleteCharacter(character);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _editCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditPage(character: character),
      ),
    ).then((_) => _loadData());
  }

  void _editRace(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceManagementPage(race: race),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).character_delete_title),
        content: Text(S.of(context).character_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _characterService.deleteCharacter(int.parse(character.id));
      if (mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).character_deleted)),
        );
      }
    }
  }

  void _createNewContent() {
    if (_selectedContentType == HomeContentType.characters) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CharacterEditPage()),
      ).then((_) => _loadData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RaceManagementPage()),
      ).then((_) => _loadData());
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewContent,
        child: const Icon(Icons.add_rounded),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Fixed header that doesn't collapse
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: colorScheme.surface,
            elevation: 1,
            shadowColor: colorScheme.shadow.withOpacity(0.1),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'CharacterBook',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ExpressiveSearchBar(
                  onChanged: _filterContent,
                  hintText: s.search_home,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ExpressiveCategoryChip(
                      label: s.characters,
                      count: _characters.length,
                      isSelected: _selectedContentType == HomeContentType.characters,
                      onTap: () => _changeContentType(HomeContentType.characters),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ExpressiveCategoryChip(
                      label: s.races,
                      count: _races.length,
                      isSelected: _selectedContentType == HomeContentType.races,
                      onTap: () => _changeContentType(HomeContentType.races),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedContentType == HomeContentType.characters)
            _buildCharactersKeepGrid()
          else
            _buildRacesKeepGrid(),

          if ((_selectedContentType == HomeContentType.characters && _filteredCharacters.isEmpty) ||
              (_selectedContentType == HomeContentType.races && _filteredRaces.isEmpty))
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedContentType == HomeContentType.characters
                          ? Icons.person_outline_rounded
                          : Icons.people_outline_rounded,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? s.no_content_home
                          : s.nothing_found,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_searchQuery.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        s.create_first_content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _createNewContent,
                        child: Text(s.create),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharactersKeepGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final character = _filteredCharacters[index];
            return _buildCharacterKeepCard(character, index);
          },
          childCount: _filteredCharacters.length,
        ),
      ),
    );
  }

  Widget _buildRacesKeepGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final race = _filteredRaces[index];
            return _buildRaceKeepCard(race, index);
          },
          childCount: _filteredRaces.length,
        ),
      ),
    );
  }
}

enum HomeContentType {
  characters,
  races,
}