import 'package:flutter/material.dart';

class ReorderableWrapper extends StatelessWidget {
  final Key key;
  final Widget child;
  final bool enableDrag;

  const ReorderableWrapper({
    required this.key,
    required this.child,
    this.enableDrag = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enableDrag) return child;

    return LongPressDraggable(
      key: key,
      data: key,
      feedback: Material(
        elevation: 8,
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: child,
    );
  }
}