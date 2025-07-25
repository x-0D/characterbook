import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';

class CustomFloatingButtons extends StatefulWidget {
  final VoidCallback? onImport;
  final VoidCallback? onAdd;
  final bool showImportButton;
  final String? importTooltip;
  final String? addTooltip;
  final VoidCallback? onTemplate;
  final String? templateTooltip;
  final String? createFromScratchTooltip;

  const CustomFloatingButtons({
    super.key,
    this.onImport,
    this.onAdd,
    this.showImportButton = true,
    this.importTooltip,
    this.addTooltip,
    this.onTemplate,
    this.templateTooltip,
    this.createFromScratchTooltip,
  });

  @override
  State<CustomFloatingButtons> createState() => _CustomFloatingButtonsState();
}

class _CustomFloatingButtonsState extends State<CustomFloatingButtons> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _translateAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  bool _isExpanded = false;

  int get _actionCount {
    int count = 0;
    if (widget.onAdd != null) count++;
    if (widget.onImport != null && widget.showImportButton) count++;
    if (widget.onTemplate != null) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _translateAnimation = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildActionButton({
    required String heroTag,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required String tooltip,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_translateAnimation.value * (index + 1)),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpanded) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            FloatingActionButton(
              heroTag: heroTag,
              onPressed: () {
                _toggleExpanded();
                onPressed();
              },
              mini: true,
              tooltip: tooltip,
              shape: const CircleBorder(),
              elevation: 2,
              highlightElevation: 4,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Icon(icon, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    if (_actionCount <= 1) {
      return FloatingActionButton(
        heroTag: 'single_action_btn',
        tooltip: widget.addTooltip ?? s.create,
        onPressed: () {
          if (widget.onAdd != null) {
            widget.onAdd!();
          } else if (widget.onImport != null && widget.showImportButton) {
            widget.onImport!();
          } else if (widget.onTemplate != null) {
            widget.onTemplate!();
          }
        },
        shape: const CircleBorder(),
        elevation: 3,
        highlightElevation: 6,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add, size: 24),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded && widget.onAdd != null)
          _buildActionButton(
            heroTag: 'create_btn',
            onPressed: widget.onAdd!,
            icon: Icons.create_outlined,
            label: widget.createFromScratchTooltip ?? s.create,
            tooltip: widget.createFromScratchTooltip ?? s.create,
            index: 0,
          ),
        if (_isExpanded && widget.showImportButton && widget.onImport != null)
          _buildActionButton(
            heroTag: 'import_btn',
            onPressed: widget.onImport!,
            icon: Icons.download_outlined,
            label: widget.importTooltip ?? s.import,
            tooltip: widget.importTooltip ?? s.import_template_tooltip,
            index: 1,
          ),
        if (_isExpanded && widget.onTemplate != null)
          _buildActionButton(
            heroTag: 'template_btn',
            onPressed: widget.onTemplate!,
            icon: Icons.library_books_outlined,
            label: widget.templateTooltip ?? s.template,
            tooltip: widget.templateTooltip ?? s.create_from_template_tooltip,
            index: 2,
          ),
        FloatingActionButton(
          heroTag: 'main_btn',
          tooltip: widget.addTooltip ?? s.create,
          onPressed: _toggleExpanded,
          shape: const CircleBorder(),
          elevation: 3,
          highlightElevation: 6,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubicEmphasized,
            switchOutCurve: Curves.easeInOutCubicEmphasized,
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.25, end: 1.0).animate(animation),
                child: ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
            },
            child: _isExpanded
                ? Icon(Icons.close, key: const ValueKey('close'))
                : Icon(Icons.add, key: const ValueKey('add')),
          ),
        ),
      ],
    );
  }
}