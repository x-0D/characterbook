import 'package:flutter/material.dart';
import 'package:characterbook/models/custom_field_model.dart';
import 'package:characterbook/generated/l10n.dart';

class CustomFieldsEditor extends StatefulWidget {
  final List<CustomField> initialFields;
  final ValueChanged<List<CustomField>> onFieldsChanged;
  final bool verticalLayout;

  const CustomFieldsEditor({
    super.key,
    required this.initialFields,
    required this.onFieldsChanged,
    this.verticalLayout = false,
  });

  @override
  State<CustomFieldsEditor> createState() => _CustomFieldsEditorState();
}

class _CustomFieldsEditorState extends State<CustomFieldsEditor> {
  late List<CustomField> _fields;

  @override
  void initState() {
    super.initState();
    _fields = widget.initialFields.map((f) => f.copyWith()).toList();
  }

  void _addField() {
    setState(() {
      _fields.add(CustomField('', ''));
    });
    widget.onFieldsChanged(_fields);
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
    widget.onFieldsChanged(_fields);
  }

  void _updateField(int index, String key, String value) {
    setState(() {
      _fields[index] = CustomField(key, value);
    });
    widget.onFieldsChanged(_fields);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    if (widget.verticalLayout) {
      return _buildVerticalLayout(s, theme);
    } else {
      return _buildHorizontalLayout(s, theme);
    }
  }

  Widget _buildVerticalLayout(S s, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Add information about the character",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addField,
              tooltip: s.create,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return _buildVerticalFieldItem(index, field, s, theme);
        }).toList(),
        if (_fields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              s.nothing_found,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalFieldItem(int index, CustomField field, S s, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: s.name,
                    hintText: s.name,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => _updateField(index, value, field.value),
                  controller: TextEditingController(text: field.key),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => _removeField(index),
                tooltip: s.delete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: s.custom_fields,
              hintText: s.custom_fields,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            onChanged: (value) => _updateField(index, field.key, value),
            controller: TextEditingController(text: field.value),
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(S s, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              s.custom_fields,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addField,
              tooltip: s.create,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _fields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return _buildHorizontalFieldItem(index, field, s, theme);
            }).toList(),
          ),
        ),
        if (_fields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              s.nothing_found,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalFieldItem(int index, CustomField field, S s, ThemeData theme) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: s.name,
              hintText: s.name,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) => _updateField(index, value, field.value),
            controller: TextEditingController(text: field.key),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: s.custom_fields,
              hintText: s.description,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) => _updateField(index, field.key, value),
            controller: TextEditingController(text: field.value),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            onPressed: () => _removeField(index),
            tooltip: s.delete,
          ),
        ],
      ),
    );
  }
}