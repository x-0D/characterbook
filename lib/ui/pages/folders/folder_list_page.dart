import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/ui/widgets/context_menu.dart';
import 'package:characterbook/ui/widgets/custom_app_bar.dart';
import 'package:characterbook/ui/widgets/custom_floating_buttons.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FoldersScreen extends StatefulWidget {
  final FolderType folderType;

  const FoldersScreen({super.key, required this.folderType});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  late Box<Folder> _folderBox;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _folderBox = Hive.box<Folder>('folders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        isSearching: _isSearching,
        searchController: _searchController,
        onSearchToggle: _toggleSearch,
        onSearchChanged: _onSearchChanged,
      ),
      body: ValueListenableBuilder(
        valueListenable: _folderBox.listenable(),
        builder: (context, box, _) {
          final folders = _getFilteredFolders();
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return _buildFolderItem(folder);
            },
          );
        },
      ),
      floatingActionButton: CustomFloatingButtons(
        onAdd: _createNewFolder,
        addTooltip: 'Создать новую папку',
      ),
    );
  }

  String _getTitle() {
    return switch (widget.folderType) {
      FolderType.character => 'Папки персонажей',
      FolderType.race => 'Папки рас',
      FolderType.note => 'Папки заметок',
      FolderType.template => 'Папки шаблонов',
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

  Widget _buildFolderItem(Folder folder) {
    return ExpansionTile(
      leading: Icon(_getFolderIcon(folder.type)),
      title: Text(folder.name),
      subtitle: Text('${folder.contentIds.length} элементов'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ..._buildSubfolders(folder),
              ..._buildFolderActions(folder),
            ],
          ),
        ),
      ],
    );
  }


  List<Widget> _buildSubfolders(Folder parentFolder) {
    final subfolders = _folderBox.values
        .where((folder) => folder.parentId == parentFolder.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return subfolders
        .map((folder) => ListTile(
              leading: Icon(_getFolderIcon(folder.type)), 
              title: Text(folder.name),
              subtitle: Text('${folder.contentIds.length} элементов'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showFolderMenu(folder),
              ),
              onTap: () => _openFolder(folder),
            ))
        .toList();
  }

  List<Widget> _buildFolderActions(Folder folder) {
    return [
      const Divider(),
      ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('Редактировать'),
        onTap: () => _editFolder(folder),
      ),
      ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Создать подпапку'),
        onTap: () => _createSubfolder(folder),
      ),
      ListTile(
        leading: const Icon(Icons.delete, color: Colors.red),
        title: const Text('Удалить', style: TextStyle(color: Colors.red)),
        onTap: () => _deleteFolder(folder),
      ),
    ];
  }

  IconData _getFolderIcon(FolderType type) {
    return switch (type) {
      FolderType.character => Icons.person,
      FolderType.race => Icons.people,
      FolderType.note => Icons.note,
      FolderType.template => Icons.library_books,
    };
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
    _showFolderDialog(null);
  }

  void _createSubfolder(Folder parent) {
    _showFolderDialog(parent);
  }

  void _editFolder(Folder folder) {
    _showFolderDialog(folder);
  }

  void _showFolderDialog(Folder? folder, {Folder? parentFolder}) {
    final controller = TextEditingController(text: folder?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(folder == null ? 'Новая папка' : 'Редактировать папку'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название папки'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _saveFolder(folder, controller.text, parentFolder);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFolder(Folder? folder, String name, Folder? parentFolder) async {
    if (folder == null) {
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: widget.folderType,
        parentId: parentFolder?.id,
      );
      await _folderBox.put(newFolder.id, newFolder);
    } else {
      folder.name = name;
      folder.updatedAt = DateTime.now();
      await folder.save();
    }
  }

  void _deleteFolder(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить папку?'),
        content: Text('Вы уверены, что хотите удалить папку "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await folder.delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openFolder(Folder folder) {
    // Здесь можно реализовать навигацию к содержимому папки
    // Например, для персонажей:
    if (folder.type == FolderType.character) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => CharactersInFolderScreen(folder: folder)));
    }
  }

  void _showFolderMenu(Folder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ContextMenu(
        item: folder,
        onEdit: () => _editFolder(folder),
        onDelete: () => _deleteFolder(folder),
        showCopy: false,
        showExportPdf: false,
        showShare: false,
      ),
    );
  }
}