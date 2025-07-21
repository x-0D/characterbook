import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../generated/l10n.dart';
import '../../../models/character_model.dart';
import '../../../models/folder_model.dart';
import '../../../models/note_model.dart';
import '../../../services/clipboard_service.dart';
import '../../../services/folder_service.dart';
import '../../widgets/fields/custom_text_field.dart';
import '../../widgets/markdown_context_menu.dart';
import '../../widgets/save_button_widget.dart';
import '../../dialogs/unsaved_changes_dialog.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;
  final bool isCopyMode;

  const NoteEditPage({super.key, this.note, this.isCopyMode = false});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final List<String> _selectedCharacterIds = [];
  bool _isPreviewMode = false;
  final GlobalKey _contentFieldKey = GlobalKey();
  bool _hasChanges = false;
  final _formKey = GlobalKey<FormState>();

  late final FolderService _folderService;
  List<Folder> _noteFolders = [];
  Folder? _selectedFolder;

  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _folderService = FolderService(Hive.box<Folder>('folders'));
    final initialTitle = widget.note?.title ?? '';
    _titleController = TextEditingController(
      text: widget.isCopyMode ? '${S.of(context).copy}: $initialTitle' : initialTitle,
    );
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCharacterIds.addAll(widget.note?.characterIds ?? []);
    _isPreviewMode = widget.note != null && !widget.isCopyMode;
    _selectedFolder = widget.note?.folderId != null 
        ? _folderService.getFolderById(widget.note!.folderId!) 
        : null;

    _titleController.addListener(_checkForChanges);
    _contentController.addListener(_checkForChanges);
    _loadFolders();

    _tags = List.from(widget.note?.tags ?? []);
  }

  Future<void> _loadFolders() async {
    final folders = _folderService.getFoldersByType(FolderType.note);
    setState(() {
      _noteFolders = folders;
    });
  }

  void _checkForChanges() {
    final hasTitleChanges = widget.note?.title != _titleController.text;
    final hasContentChanges = widget.note?.content != _contentController.text;
    setState(() {
      _hasChanges = hasTitleChanges || hasContentChanges;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkForChanges);
    _contentController.removeListener(_checkForChanges);
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).save_error)),
      );
      return;
    }

    final notesBox = Hive.box<Note>('notes');
    final now = DateTime.now();

    int? noteKey;
    if (widget.note != null && !widget.isCopyMode) {
      widget.note!
        ..title = title
        ..content = _contentController.text.trim()
        ..characterIds = _selectedCharacterIds
        ..folderId = _selectedFolder?.id
        ..updatedAt = now
        ..tags = _tags;
      await notesBox.put(widget.note!.key, widget.note!);
      noteKey = widget.note!.key;
    } else {
      noteKey = await notesBox.add(Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        content: _contentController.text.trim(),
        characterIds: _selectedCharacterIds,
        folderId: _selectedFolder?.id,
        tags: _tags,
      ));
    }

    if (noteKey != null) {
      if (_selectedFolder == null) {
        for (final folder in _noteFolders) {
          if (folder.contentIds.contains(noteKey.toString())) {
            await _folderService.removeFromFolder(folder.id, noteKey.toString());
          }
        }
      } else {
        for (final folder in _noteFolders) {
          if (folder.id != _selectedFolder!.id && 
              folder.contentIds.contains(noteKey.toString())) {
            await _folderService.removeFromFolder(folder.id, noteKey.toString());
          }
        }
        await _folderService.addToFolder(_selectedFolder!.id, noteKey.toString());
      }
    }

    setState(() => _hasChanges = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _copyToClipboard() async {
    final charactersBox = Hive.box<Character>('characters');
    final _ = _selectedCharacterIds.map((id) {
      final character = charactersBox.get(id);
      return character?.name ?? S.of(context).no_data_found;
    }).toList();

    await ClipboardService.copyNoteToClipboard(
      context: context,
      content: _contentController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).operationCompleted)),
      );
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
                  itemCount: _noteFolders.length + 1,
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

                    final folder = _noteFolders[index - 1];
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
        _hasChanges = true;
      });
    }
  }

  Widget _buildTagsInput(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).tags,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) => Chip(
            label: Text(tag),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _tags.remove(tag);
                _hasChanges = true;
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: S.of(context).add_tag,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                onSubmitted: (tag) {
                  if (tag.trim().isNotEmpty && !_tags.contains(tag)) {
                    setState(() {
                      _tags.add(tag.trim());
                      _hasChanges = true;
                    });
                    _tagController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final tag = _tagController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                    _hasChanges = true;
                  });
                  _tagController.clear();
                }
              },
              tooltip: S.of(context).add_tag,
            ),
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) return true;
        final shouldSave = await UnsavedChangesDialog(
          saveText: S.of(context).save,
        ).show(context);
        if (shouldSave == null) return false;
        if (shouldSave) await _saveNote();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null
                ? S.of(context).create
                : widget.isCopyMode
                ? '${S.of(context).copy} ${S.of(context).posts.toLowerCase()}'
                : S.of(context).edit,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: _copyToClipboard,
              tooltip: S.of(context).copy,
            ),
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
              onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
              tooltip: _isPreviewMode ? S.of(context).edit : S.of(context).empty_list,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: S.of(context).save,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTagsInput(context),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _titleController,
            label: S.of(context).name,
            isRequired: true,
            onChanged: (value) => _checkForChanges(),
          ),
          if (_noteFolders.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectFolder(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: S.of(context).folder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            _hasChanges = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildCharacterSelector(context),
          const SizedBox(height: 16),
          _buildSelectedCharactersChips(context),
          const SizedBox(height: 16),
          _buildContentField(),
          const SizedBox(height: 24),
          SaveButton(
            onPressed: _saveNote,
            text: S.of(context).save,
          ),
        ],
      ),
    );
  }

  Widget _buildContentField() {
    if (_isPreviewMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: MarkdownBody(
          data: _contentController.text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
        ),
      );
    }

    return CustomTextField(
      key: _contentFieldKey,
      controller: _contentController,
      label: S.of(context).description,
      maxLines: null,
      alignLabel: true,
      keyboardType: TextInputType.multiline,
      onChanged: (value) => _checkForChanges(),
      contextMenuBuilder: (context, editableTextState) {
        return MarkdownContextMenu(
          controller: _contentController,
          editableTextState: editableTextState,
        );
      },
    );
  }

  Widget _buildCharacterSelector(BuildContext context) {
    final characters = Hive.box<Character>('characters').values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: null,
          decoration: InputDecoration(
            labelText: '${S.of(context).create} ${S.of(context).character.toLowerCase()}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          style: Theme.of(context).textTheme.bodyLarge,
          borderRadius: BorderRadius.circular(12),
          items: characters.map((character) {
            final characterKey = Hive.box<Character>('characters')
                .keyAt(characters.indexOf(character))
                .toString();
            final isSelected = _selectedCharacterIds.contains(characterKey);
            return DropdownMenuItem(
              value: characterKey,
              child: Row(
                children: [
                  if (isSelected)
                    Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20),
                  const SizedBox(width: 8),
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCharacterIds.contains(value)
                    ? _selectedCharacterIds.remove(value)
                    : _selectedCharacterIds.add(value);
                _hasChanges = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedCharactersChips(BuildContext context) {
    final charactersBox = Hive.box<Character>('characters');

    if (_selectedCharacterIds.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedCharacterIds.map((characterId) {
        final character = charactersBox.get(characterId);
        return character != null
            ? _buildCharacterChip(character, characterId)
            : const SizedBox();
      }).toList(),
    );
  }

  Widget _buildCharacterChip(Character character, String characterId) {
    return InputChip(
      label: Text(character.name),
      onDeleted: () => setState(() {
        _selectedCharacterIds.remove(characterId);
        _hasChanges = true;
      }),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}