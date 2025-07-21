import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../generated/l10n.dart';
import '../../../models/race_model.dart';
import '../../../models/folder_model.dart';
import '../../../services/folder_service.dart';
import '../../widgets/avatar_picker_widget.dart';
import '../../widgets/fields/custom_text_field.dart';
import '../../widgets/save_button_widget.dart';
import '../../dialogs/unsaved_changes_dialog.dart';

class RaceManagementPage extends StatefulWidget {
  final Race? race;

  const RaceManagementPage({super.key, this.race});

  @override
  State<RaceManagementPage> createState() => _RaceManagementPageState();
}

class _RaceManagementPageState extends State<RaceManagementPage> {
  static const _logoSize = 120.0;
  static const _borderRadius = 12.0;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _biologyController;
  late final TextEditingController _backstoryController;
  Uint8List? _logoBytes;

  bool _hasUnsavedChanges = false;

  late final FolderService _folderService;
  List<Folder> _raceFolders = [];
  Folder? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _folderService = FolderService(Hive.box<Folder>('folders'));
    final race = widget.race;
    _nameController = TextEditingController(text: race?.name ?? '');
    _descriptionController = TextEditingController(text: race?.description ?? '');
    _biologyController = TextEditingController(text: race?.biology ?? '');
    _backstoryController = TextEditingController(text: race?.backstory ?? '');
    _logoBytes = race?.logo;
    _hasUnsavedChanges = widget.race == null;
    _setupControllers();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = _folderService.getFoldersByType(FolderType.race);
    setState(() {
      _raceFolders = folders;
      _selectedFolder = widget.race?.folderId != null 
        ? _folderService.getFolderById(widget.race!.folderId!) 
        : null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _biologyController.dispose();
    _backstoryController.dispose();
    super.dispose();
  }

  void _setupControllers() {
    _nameController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _descriptionController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _biologyController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _backstoryController.addListener(() => setState(() => _hasUnsavedChanges = true));
  }

  Future<void> _saveRace() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.isEmpty) {
      _showError(S.of(context).enter_race_name);
      return;
    }

    try {
      final raceBox = Hive.box<Race>('races');
      final race = widget.race ?? Race(name: _nameController.text)
        ..name = _nameController.text
        ..description = _descriptionController.text
        ..biology = _biologyController.text
        ..backstory = _backstoryController.text
        ..logo = _logoBytes
        ..folderId = _selectedFolder?.id;

      int? raceKey;
      if (widget.race == null) {
        raceKey = await raceBox.add(race);
      } else {
        await race.save();
        raceKey = widget.race!.key;
      }

      if (raceKey != null) {
        if (_selectedFolder == null) {
          for (final folder in _raceFolders) {
            if (folder.contentIds.contains(raceKey.toString())) {
              await _folderService.removeFromFolder(folder.id, raceKey.toString());
            }
          }
        } else {
          for (final folder in _raceFolders) {
            if (folder.id != _selectedFolder!.id && 
                folder.contentIds.contains(raceKey.toString())) {
              await _folderService.removeFromFolder(folder.id, raceKey.toString());
            }
          }
          await _folderService.addToFolder(_selectedFolder!.id, raceKey.toString());
        }
      }

      setState(() => _hasUnsavedChanges = false);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('${S.of(context).save_error}: $e');
    }
  }

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
      builder: (context) => Padding(
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
                  itemCount: _raceFolders.length + 1,
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

                    final folder = _raceFolders[index - 1];
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
      ),
    );

    if (selected != null || _selectedFolder != null) {
      setState(() {
        _selectedFolder = selected;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (!_hasUnsavedChanges) return true;
        final shouldSave = await UnsavedChangesDialog(
          saveText: s.save_race,
        ).show(context);
        if (shouldSave == null) return false;
        if (shouldSave) await _saveRace();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.race == null ? s.new_race : s.edit_race,
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRace,
              tooltip: s.save,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPicker(
                  currentAvatar: _logoBytes,
                  onAvatarChanged: (bytes) {
                    setState(() {
                      _logoBytes = bytes;
                      _hasUnsavedChanges = true;
                    });
                  },
                  size: _logoSize / 2,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: s.race_name,
                  isRequired: true,
                ),
                if (_raceFolders.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectFolder(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: s.folder,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedFolder?.name ?? s.no_folder_selected,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _selectedFolder == null 
                                  ? theme.colorScheme.onSurface 
                                  : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (_selectedFolder != null)
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              style: IconButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedFolder = null;
                                  _hasUnsavedChanges = true;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: s.description,
                  maxLines: 3,
                  alignLabel: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _biologyController,
                  label: s.biology,
                  maxLines: 5,
                  alignLabel: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _backstoryController,
                  label: s.backstory,
                  maxLines: 7,
                  alignLabel: true,
                ),
                const SizedBox(height: 32),
                SaveButton(
                  onPressed: _saveRace,
                  text: s.save_race,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}