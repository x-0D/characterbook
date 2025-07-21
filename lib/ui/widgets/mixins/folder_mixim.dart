import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:characterbook/services/folder_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

mixin FolderMixin<T extends StatefulWidget> on State<T> {
  late final FolderService _folderService;
  List<Folder> _folders = [];
  Folder? _selectedFolder;
  late final FolderType folderType;

  @override
  void initState() {
    super.initState();
    _folderService = FolderService(Hive.box<Folder>('folders'));
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = _folderService.getFoldersByType(folderType);
    setState(() {
      _folders = folders;
      _selectedFolder = getInitialSelectedFolder();
    });
  }

  Folder? getInitialSelectedFolder();

  Future<void> _selectFolder(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selected = await showModalBottomSheet<Folder>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _buildFolderSelectionDialog(
        context,
        colorScheme,
        textTheme,
      ),
    );

    if (selected != null || _selectedFolder != null) {
      setState(() {
        _selectedFolder = selected;
        onFolderSelected(selected);
      });
    }
  }

  Widget _buildFolderSelectionDialog(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  S.of(context).select_folder,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _folders.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Icon(
                        Icons.folder_off,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        S.of(context).none,
                        style: textTheme.bodyLarge,
                      ),
                      onTap: () => Navigator.pop(context, null),
                    );
                  }

                  final folder = _folders[index - 1];
                  return ListTile(
                    leading: Icon(
                      Icons.folder,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      folder.name,
                      style: textTheme.bodyLarge,
                    ),
                    trailing: _selectedFolder?.id == folder.id
                        ? Icon(
                            Icons.check,
                            color: colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, folder),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFolderInput(BuildContext context) {
    if (_folders.isEmpty) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 16),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectFolder(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: S.of(context).folder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 16,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedFolder?.name ?? S.of(context).no_folder_selected,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _selectedFolder == null 
                        ? Theme.of(context).colorScheme.onSurface 
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_selectedFolder != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFolder = null;
                        onFolderSelected(null);
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void onFolderSelected(Folder? folder);
}