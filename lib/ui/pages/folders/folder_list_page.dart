import 'package:characterbook/ui/pages/characters/character_management_page.dart';
import 'package:characterbook/ui/pages/notes/note_management_page.dart';
import 'package:characterbook/ui/pages/races/race_management_page.dart';
import 'package:characterbook/ui/widgets/items/character_card.dart';
import 'package:characterbook/ui/widgets/items/note_card.dart';
import 'package:characterbook/ui/widgets/items/race_card.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/models/note_model.dart';
import 'package:characterbook/ui/widgets/custom_app_bar.dart';
import 'package:characterbook/ui/widgets/custom_floating_buttons.dart';
import 'package:characterbook/ui/widgets/context_menu.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../generated/l10n.dart';

class FoldersScreen extends StatefulWidget {
  final FolderType folderType;

  const FoldersScreen({super.key, required this.folderType});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late Box<Folder> _folderBox;
  late Box<Character> _characterBox;
  late Box<Race> _raceBox;
  late Box<Note> _noteBox;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _folderBox = Hive.box<Folder>('folders');
    _characterBox = Hive.box<Character>('characters');
    _raceBox = Hive.box<Race>('races');
    _noteBox = Hive.box<Note>('notes');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(s),
        isSearching: _isSearching,
        searchController: _searchController,
        searchHint: s.search_hint,
        onSearchToggle: _toggleSearch,
        onSearchChanged: _onSearchChanged,
      ),
      body: ValueListenableBuilder(
        valueListenable: _folderBox.listenable(),
        builder: (context, box, _) {
          final folders = _getFilteredFolders();
          
          if (folders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getFolderIcon(widget.folderType),
                    size: 48,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.none,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.create,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return _buildFolderItem(folder, colorScheme, textTheme, s);
            },
          );
        },
      ),
      floatingActionButton: CustomFloatingButtons(
        onAdd: _createNewFolder,
        addTooltip: s.create,
      ),
    );
  }

  String _getTitle(S s) {
    return switch (widget.folderType) {
      FolderType.character => s.characters,
      FolderType.race => s.races,
      FolderType.note => s.posts,
      FolderType.template => s.templates,
    };
  }

  List<Folder> _getFilteredFolders() {
    return _folderBox.values
        .where((folder) => 
          folder.type == widget.folderType &&
          (folder.parentId == null || folder.parentId!.isEmpty) &&
          (_searchQuery.isEmpty || 
           folder.name.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Widget _buildFolderItem(Folder folder, ColorScheme colorScheme, TextTheme textTheme, S s) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: folder.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getFolderIcon(folder.type),
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          folder.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${folder.contentIds.length} ${_getContentLabel(folder.contentIds.length, s)}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => _showFolderContextMenu(folder, s),
        ),
        children: _buildFolderContents(folder),
      ),
    );
  }

  List<Widget> _buildFolderContents(Folder folder) {
    switch (folder.type) {
      case FolderType.character:
        return _buildCharacterContents(folder);
      case FolderType.race:
        return _buildRaceContents(folder);
      case FolderType.note:
        return _buildNoteContents(folder);
      case FolderType.template:
        return [];
    }
  }

  List<Widget> _buildCharacterContents(Folder folder) {
    final characters = _characterBox.values
        .where((character) => folder.contentIds.contains(character.key.toString()))
        .toList();

    if (characters.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).characters,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return characters.map((character) => CharacterCard(
      character: character,
      isSelected: false,
      onTap: () => _openCharacter(character),
      onLongPress: () => _showCharacterContextMenu(character),
      onMenuPressed: () => _showCharacterContextMenu(character),
    )).toList();
  }

  List<Widget> _buildRaceContents(Folder folder) {
    final races = _raceBox.values
        .where((race) => folder.contentIds.contains(race.key.toString()))
        .toList();

    if (races.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).races,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return races.map((race) => RaceCard(
      race: race,
      onTap: () => _openRace(race),
      onLongPress: () => _showRaceContextMenu(race),
    )).toList();
  }

  List<Widget> _buildNoteContents(Folder folder) {
    final notes = _noteBox.values
        .where((note) => folder.contentIds.contains(note.id))
        .toList();

    if (notes.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).posts,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return notes.map((note) => NoteCard(
      note: note,
      onTap: () => _openNote(note),
      onEdit: () => _editNote(note),
      onDelete: () => _deleteNote(note),
    )).toList();
  }

  String _getContentLabel(int count, S s) {
    if (count % 10 == 1 && count % 100 != 11) return s.none;
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return s.none;
    }
    return s.none;
  }

  IconData _getFolderIcon(FolderType type) {
    return Icons.folder_outlined;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _createNewFolder() {
    _showFolderDialog(null, null, S.of(context));
  }

  void _showFolderContextMenu(Folder folder, S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => ContextMenu(
        item: folder,
        onEdit: () => _editFolder(folder, s),
        onDelete: () => _deleteFolder(folder, s),
        showExportPdf: false,
        showCopy: false,
        showShare: false,
      ),
    );
  }

  void _showFolderDialog(Folder? folder, Folder? parentFolder, S s) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: folder?.name ?? '');
    int selectedColor = folder?.colorValue ?? 0xFF6200EE;

    final List<int> colorOptions = [
      0xFF6200EE, // Purple
      0xFF03DAC6, // Teal
      0xFF018786, // Dark Teal
      0xFFBB86FC, // Light Purple
      0xFFFF7597, // Pink
      0xFFFF0266, // Hot Pink
      0xFF6750A4, // Deep Purple
      0xFF1E88E5, // Blue
      0xFF4CAF50, // Green
      0xFFFF9800, // Orange
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              folder == null ? s.new_folder : s.edit_folder,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: s.folder_name,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                autofocus: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.folder_color,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorOptions.length,
                      itemBuilder: (context, index) {
                        final color = colorOptions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(color),
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(
                                        color: colorScheme.onSurface,
                                        width: 2,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(s.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          _saveFolder(folder, controller.text, parentFolder, selectedColor);
                          Navigator.pop(context);
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(s.save),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFolder(Folder? folder, String name, Folder? parentFolder, int colorValue) async {
    if (folder == null) {
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: widget.folderType,
        parentId: parentFolder?.id,
        colorValue: colorValue,
      );
      await _folderBox.put(newFolder.id, newFolder);
    } else {
      folder.name = name;
      folder.colorValue = colorValue;
      folder.updatedAt = DateTime.now();
      await folder.save();
    }
  }

  void _deleteFolder(Folder folder, S s) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          s.delete,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          s.delete,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              s.cancel,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              await folder.delete();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              s.delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditPage(character: character),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showCharacterContextMenu(Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => ContextMenu(
        item: character,
        onEdit: () => _openCharacter(character),
        onDelete: () => _deleteCharacter(character),
        showExportPdf: true,
        showCopy: true,
        showShare: true,
      ),
    );
  }

  Future<void> _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete),
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
      await character.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).character_deleted)),
        );
      }
    }
  }

  void _openRace(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceManagementPage(race: race),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showRaceContextMenu(Race race) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      builder: (context) => ContextMenu(
        item: race,
        onEdit: () => _openRace(race),
        onDelete: () => _deleteRace(race),
        showExportPdf: false,
        showCopy: false,
        showShare: false,
      ),
    );
  }

  Future<void> _deleteRace(Race race) async {
    final isUsed = await isRaceUsed(race);
    if (isUsed) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).race_delete_error_title),
            content: Text(S.of(context).race_delete_error_content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ],
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete),
        content: Text(S.of(context).race_delete_confirm),
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
      await race.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).race_deleted)),
        );
      }
    }
  }


  Future<bool> isRaceUsed(Race race) async {
    final characters = _characterBox.values;
    return characters.any((character) => character.race?.key == race.key);
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(note: note),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>NoteEditPage(note: note),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete),
        content: Text('${S.of(context).posts} "${note.title}" ${S.of(context).template_delete_confirm}'),
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
      await note.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).posts} "${note.title}" ${S.of(context).template_deleted}'),
            action: SnackBarAction(
              label: S.of(context).cancel,
              onPressed: () => _noteBox.add(note),
            ),
          ),
        );
      }
    }
  }

  void _editFolder(Folder folder, S s) {
    _showFolderDialog(folder, null, s);
  }
}