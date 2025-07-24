import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/models/folder_model.dart';
import 'package:flutter/material.dart';

class FolderDialog extends StatefulWidget {
  final Folder? folder;
  final Folder? parentFolder;
  final FolderType folderType;
  final Function(Folder?, String, Folder?, int) onSave;

  const FolderDialog({
    super.key,
    this.folder,
    this.parentFolder,
    required this.folderType,
    required this.onSave,
  });

  @override
  State<FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<FolderDialog> {
  late TextEditingController _controller;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.folder?.name ?? '');
    _selectedColor = widget.folder?.colorValue ?? 0xFF6200EE;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

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

    return Padding(
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
            widget.folder == null ? s.new_folder : s.edit_folder,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
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
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: _selectedColor == color
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
                      if (_controller.text.isNotEmpty) {
                        widget.onSave(
                          widget.folder,
                          _controller.text,
                          widget.parentFolder,
                          _selectedColor,
                        );
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
    );
  }
}