import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'keep_card_item.dart';

typedef FlipSideBuilder = Widget Function(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  double flipValue,
  bool isFrontSide,
);

class FlipKeepCardItem extends StatefulWidget {
  final FlipSideBuilder frontBuilder;
  final FlipSideBuilder backBuilder;
  final VoidCallback? onTap;
  final VoidCallback? onContextMenuTap;
  final bool autoFlipEnabled;
  final Duration minFlipInterval;
  final Duration maxFlipInterval;

  const FlipKeepCardItem({
    super.key,
    required this.frontBuilder,
    required this.backBuilder,
    this.onTap,
    this.onContextMenuTap,
    this.autoFlipEnabled = true,
    this.minFlipInterval = const Duration(seconds: 3),
    this.maxFlipInterval = const Duration(seconds: 8),
  });

  @override
  State<FlipKeepCardItem> createState() => _FlipKeepCardState();
}

class _FlipKeepCardState extends State<FlipKeepCardItem>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  Timer? _flipTimer;
  bool _isFront = true;
  bool _isHovering = false;
  bool _isAnimating = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    if (widget.autoFlipEnabled) {
      _scheduleNextFlip();
    }
  }

  void _scheduleNextFlip() {
    _flipTimer?.cancel();
    if (!widget.autoFlipEnabled || _isHovering) return;

    final delayMs = _random.nextInt(
          widget.maxFlipInterval.inMilliseconds -
              widget.minFlipInterval.inMilliseconds +
              1,
        ) +
        widget.minFlipInterval.inMilliseconds;

    _flipTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && !_isHovering && !_isAnimating) {
        _performFlip();
      } else if (mounted) {
        // Если условия не выполнены (например, наведение), попробуем позже
        _scheduleNextFlip();
      }
    });
  }

  Future<void> _performFlip() async {
    if (_isAnimating) return;
    _isAnimating = true;

    final target = !_isFront;
    if (target) {
      await _flipController.forward();
    } else {
      await _flipController.reverse();
    }

    if (mounted) {
      setState(() {
        _isFront = target;
      });
      _isAnimating = false;
      // Планируем следующий переворот
      _scheduleNextFlip();
    }
  }

  void _onEnter() {
    setState(() {
      _isHovering = true;
    });
    _flipTimer?.cancel();
  }

  void _onExit() {
    setState(() {
      _isHovering = false;
    });
    if (widget.autoFlipEnabled && mounted) {
      _scheduleNextFlip();
    }
  }

  @override
  void dispose() {
    _flipTimer?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeepCardItem(
      onTap: widget.onTap,
      onEnter: _onEnter,
      onExit: _onExit,
      onSecondaryTap: widget.onContextMenuTap,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: _flipAnimation.value <= 0.5 ? 1.0 : 0.0,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
                  alignment: Alignment.center,
                  child: _buildSide(isFront: true),
                ),
              ),
              Opacity(
                opacity: _flipAnimation.value > 0.5 ? 1.0 : 0.0,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY((_flipAnimation.value - 1) * 3.14159),
                  alignment: Alignment.center,
                  child: _buildSide(isFront: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSide({required bool isFront}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return isFront
            ? widget.frontBuilder(
                context, theme, colorScheme, _flipAnimation.value, true)
            : widget.backBuilder(
                context, theme, colorScheme, _flipAnimation.value, false);
      },
    );
  }
}
