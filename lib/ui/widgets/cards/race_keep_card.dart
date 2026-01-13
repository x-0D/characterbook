import 'package:flutter/material.dart';
import 'package:characterbook/models/race_model.dart';
import 'package:characterbook/generated/l10n.dart';
import 'dart:async';

class RaceKeepCard extends StatefulWidget {
  final Race race;
  final int characterCount;
  final VoidCallback onTap;
  final VoidCallback onContextMenuTap;
  final bool isAnimating;
  final double tileSize;

  const RaceKeepCard({
    super.key,
    required this.race,
    required this.characterCount,
    required this.onTap,
    required this.onContextMenuTap,
    this.isAnimating = false,
    this.tileSize = 1.0,
  });

  @override
  State<RaceKeepCard> createState() => _RaceKeepCardState();
}

class _RaceKeepCardState extends State<RaceKeepCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _flipController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _flipAnimation;
  Timer? _flipTimer;
  bool _isFront = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _startFlipTimer();
  }

  void _startFlipTimer() {
    _flipTimer?.cancel();
    _flipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && !_isHovering && !_flipController.isAnimating) {
        _flipCard();
      }
    });
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;

    setState(() {
      _isFront = !_isFront;
    });

    _flipController.forward().then((_) {
      Timer(const Duration(seconds: 4), () {
        if (mounted && !_isHovering) {
          setState(() {
            _isFront = !_isFront;
          });
          _flipController.reverse();
        }
      });
    });
  }

  @override
  void didUpdateWidget(RaceKeepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startPulseAnimation();
    }
  }

  void _startPulseAnimation() {
    _tapController.forward().then((_) => _tapController.reverse());
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _tapController.reverse();
    });
  }

  void _handleTapCancel() {
    if (mounted) _tapController.reverse();
  }

  @override
  void dispose() {
    _flipTimer?.cancel();
    _tapController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Widget _buildFrontSide(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: widget.race.logo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.memory(
                      widget.race.logo!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.people_rounded,
                    size: 28.0,
                    color: colorScheme.primary,
                  ),
          ),
          Text(
            widget.race.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14.0,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4.0),
                Text(
                  '${widget.characterCount}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 2.0),
                Text(
                  S.of(context).characters.toLowerCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.0,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Описание расы',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                widget.race.description.isNotEmpty
                    ? widget.race.description
                    : S.of(context).no_description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                  height: 1.4,
                ),
                maxLines: 6,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          if (widget.race.tags.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Теги расы:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4.0),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: widget.race.tags
                      .take(4)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.flip_rounded,
              size: 16.0,
              color: colorScheme.onPrimaryContainer.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovering = false;
          });
          _startFlipTimer();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_tapController, _flipController]),
          builder: (context, child) {
            final flipValue = _flipAnimation.value;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipValue * 3.1415927),
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(6.0),
                constraints: const BoxConstraints(
                  minWidth: 160,
                  minHeight: 160,
                  maxWidth: 180,
                  maxHeight: 180,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8.0 * _elevationAnimation.value,
                      offset: Offset(0, 2.0 * _elevationAnimation.value),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: widget.onTap,
                    splashColor: colorScheme.primary.withOpacity(0.2),
                    highlightColor: colorScheme.primary.withOpacity(0.1),
                    child: Stack(
                      children: [
                        if (flipValue > 0.5 || !_isFront)
                          _buildBackSide(context, theme, colorScheme),

                        if (flipValue <= 0.5 || _isFront)
                          _buildFrontSide(context, theme, colorScheme),

                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20.0,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              onPressed: widget.onContextMenuTap,
                              splashRadius: 20.0,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32.0,
                                minHeight: 32.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
