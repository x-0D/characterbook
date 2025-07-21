import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

mixin TagsMixin<T extends StatefulWidget> on State<T> {
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(getInitialTags());
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  List<String> getInitialTags();

  Widget buildTagsInput(BuildContext context) {
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
                onTagRemoved(tag);
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
                onSubmitted: (tag) => _addTag(tag.trim()),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_tagController.text.trim()),
              tooltip: S.of(context).add_tag,
            ),
          ],
        ),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        onTagAdded(tag);
      });
    }
  }

  void onTagAdded(String tag);
  void onTagRemoved(String tag);
}