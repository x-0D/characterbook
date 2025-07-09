import 'package:characterbook/models/character_model.dart';
import 'package:characterbook/ui/widgets/items/character_list_card.dart';
import 'package:characterbook/ui/widgets/tag_filter.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class CharacterListView extends StatefulWidget {
  final List<Character> allCharacters;
  final List<Character> charactersToShow;
  final List<String> tags;
  final TextEditingController searchController;
  final bool isSearching;
  final String? selectedTag;
  final Function(int, int) onReorder;
  final Function(Character) onCharacterTap;
  final Function(Character) onCharacterLongPress;
  final Function(String?) onTagSelected;

  const CharacterListView({
    super.key,
    required this.allCharacters,
    required this.charactersToShow,
    required this.tags,
    required this.searchController,
    required this.isSearching,
    required this.selectedTag,
    required this.onReorder,
    required this.onCharacterTap,
    required this.onCharacterLongPress,
    required this.onTagSelected,
  });

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.tags.isNotEmpty)
          TagFilter(
            tags: widget.tags,
            selectedTag: widget.selectedTag,
            onTagSelected: widget.onTagSelected,
            allCharacters: widget.allCharacters,
          ),
        Expanded(
          child: _buildCharactersList(),
        ),
      ],
    );
  }

  Widget _buildCharactersList() {
    if (widget.charactersToShow.isEmpty) {
      return Center(
        child: Text(
          widget.isSearching && widget.searchController.text.isNotEmpty
              ? 'Nothing found'
              : 'No characters',
        ),
      );
    }

    return Listener(
      onPointerDown: (_) => _isDragging = false,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        scrollController: _scrollController,
        itemCount: widget.charactersToShow.length,
        itemBuilder: (context, index) {
          final character = widget.charactersToShow[index];
          return _buildCharacterCard(character, index);
        },
        onReorderStart: (index) {
          HapticFeedback.lightImpact();
          setState(() => _isDragging = true);
        },
        onReorderEnd: (_) => setState(() => _isDragging = false),
        onReorder: widget.onReorder,
      ),
    );
  }

  Widget _buildCharacterCard(Character character, int index) {
    return ReorderableDragStartListener(
      key: ValueKey(character.key),
      index: index,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          if (!_isDragging && details.primaryDelta != null) {
            _scrollController.jumpTo(
              _scrollController.offset - details.primaryDelta!,
            );
          }
        },
        child: CharacterListCard(
          key: ValueKey(character.key),
          character: character,
          isSelected: false,
          onTap: () => widget.onCharacterTap(character),
          onLongPress: () => widget.onCharacterLongPress(character),
          onMenuPressed: () => widget.onCharacterLongPress(character),
          enableDrag: true,
        ),
      ),
    );
  }
}

