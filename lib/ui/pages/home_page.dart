import 'dart:async';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/services/character_service.dart';
import 'package:characterbook/services/date_formatter.dart';
import 'package:characterbook/services/race_service.dart';
import 'package:characterbook/ui/modals/character_modal_card.dart';
import 'package:characterbook/ui/modals/race_modal_card.dart';
import 'package:characterbook/ui/controllers/home_controller.dart';
import 'package:characterbook/ui/pages/character_management_page.dart';
import 'package:characterbook/ui/pages/race_management_page.dart';
import 'package:characterbook/ui/pages/settings_page.dart';
import 'package:characterbook/ui/widgets/appbar/search_app_bar.dart';
import 'package:characterbook/ui/widgets/buttons/common_list_floating_buttons.dart';
import 'package:characterbook/ui/widgets/cards/character_keep_card.dart';
import 'package:characterbook/ui/widgets/cards/race_keep_card.dart';
import 'package:characterbook/ui/widgets/cards/tool_keep_card.dart';
import 'package:characterbook/ui/widgets/items/home_item.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    final characterService = context.read<CharacterService>();
    final raceService = context.read<RaceService>();
    _controller = HomeController(
      characterService: characterService,
      raceService: raceService,
    );
    _loadData();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _controller.loadData();
      if (mounted) setState(() {});
    } catch (e) {

    }
  }

  Future<void> _createNewContent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CharacterManagementPage()),
    );
    if (result == true && mounted) {
      await _loadData();
    }
  }

  void _importContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).import_cancelled)),
    );
  }

  void _createFromTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${S.of(context).templates_not_found} - ${S.of(context).import_cancelled}',
        ),
      ),
    );
  }

  void _navigateToTool(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: SearchAppBar(
          title: s.app_name,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/iconapp.png',
              height: 32,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.book_rounded, size: 32),
            ),
          ),
          suggestions: _controller.getAllNamesForSuggestions(),
          onSubmitted: (value) => _controller.setSearchQuery(value),
          onChanged: (value) => _controller.setSearchQuery(value),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: s.more_options,
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Настройки'),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: CommonListFloatingButtons(
          onAdd: _createNewContent,
          onImport: _importContent,
          onTemplate: _createFromTemplate,
          showImportButton: true,
          addTooltip: s.new_character,
          importTooltip: s.import,
          templateTooltip: s.create_from_template_tooltip,
          createFromScratchTooltip: s.new_character,
          heroTag: "home_list",
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Expanded(
                child: Consumer<HomeController>(
                  builder: (context, controller, _) {
                    if (!controller.hasItems &&
                        controller.searchQuery.isEmpty) {
                      return _EmptyState(
                        isSearching: false,
                        onCreateNew: _createNewContent,
                      );
                    }
                    return _ContentGrid(
                      controller: controller,
                      onCharacterTap: _showCharacterDetail,
                      onCharacterContextMenu: _showCharacterContextMenu,
                      onRaceTap: _showRaceDetail,
                      onRaceContextMenu: _showRaceContextMenu,
                      onToolTap: (tool) => _navigateToTool(tool.page),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCharacterDetail(CharacterHomeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterModalCard(character: item.character),
    );
  }

  void _showCharacterContextMenu(CharacterHomeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.character(
        character: item.character,
        onEdit: () {
          Navigator.pop(context);
          _editCharacter(item.character);
        },
        onDelete: () => _showDeleteDialog(item),
      ),
    );
  }

  void _showRaceDetail(RaceHomeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RaceModalCard(race: item.race),
    );
  }

  void _showRaceContextMenu(RaceHomeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextMenu.race(
        race: item.race,
        onEdit: () {
          Navigator.pop(context);
          _editRace(item.race);
        },
        onDelete: () => _showDeleteDialog(item),
      ),
    );
  }

  Future<void> _editCharacter(Character character) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterManagementPage(character: character),
      ),
    );
    if (result == true && mounted) await _loadData();
  }

  Future<void> _editRace(Race race) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceManagementPage(race: race),
      ),
    );
    if (result == true && mounted) await _loadData();
  }

  Future<void> _showDeleteDialog(HomeItem item) async {
    final s = S.of(context);
    final isCharacter = item is CharacterHomeItem;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(isCharacter ? s.character_delete_title : s.race_delete_title),
        content: Text(
            isCharacter ? s.character_delete_confirm : s.race_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              s.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _controller.deleteItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCharacter ? s.character_deleted : s.race_deleted,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.delete_error}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _ContentGrid extends StatelessWidget {
  const _ContentGrid({
    required this.controller,
    required this.onCharacterTap,
    required this.onCharacterContextMenu,
    required this.onRaceTap,
    required this.onRaceContextMenu,
    required this.onToolTap,
  });

  final HomeController controller;
  final void Function(CharacterHomeItem) onCharacterTap;
  final void Function(CharacterHomeItem) onCharacterContextMenu;
  final void Function(RaceHomeItem) onRaceTap;
  final void Function(RaceHomeItem) onRaceContextMenu;
  final void Function(ToolHomeItem) onToolTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              (constraints.maxWidth / 180).floor().clamp(2, 5);
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: controller.filteredItems.length,
            itemBuilder: (context, index) {
              final item = controller.filteredItems[index];
              return switch (item) {
                CharacterHomeItem(:final character) => CharacterKeepCard(
                    character: character,
                    onTap: () => onCharacterTap(item),
                    onContextMenuTap: () => onCharacterContextMenu(item),
                    formattedDate:
                        character.lastEdited.toRelativeString(context),
                  ),
                RaceHomeItem(:final race) => RaceKeepCard(
                    race: race,
                    characterCount: controller.characterCountForRace(race),
                    onTap: () => onRaceTap(item),
                    onContextMenuTap: () => onRaceContextMenu(item),
                  ),
                ToolHomeItem() => ToolKeepCard(
                    title: item.getTitle(context),
                    subtitle: item.getSubtitle(context),
                    icon: item.getIcon(),
                    iconColor: Theme.of(context).colorScheme.primary,
                    onTap: () => onToolTap(item),
                  ),
              };
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isSearching,
    required this.onCreateNew,
  });

  final bool isSearching;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? s.nothing_found : s.no_content_home,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
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
                onPressed: onCreateNew,
                child: Text(s.create),
              ),
            ],
          ],
        ),
      ),
    );
  }
}