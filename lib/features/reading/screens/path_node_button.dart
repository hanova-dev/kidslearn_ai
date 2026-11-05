import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../controllers/path_node.dart';

/// One round story button on the path: green = finished, big blue = next, grey lock = locked.
class PathNodeButton extends StatelessWidget {
  const PathNodeButton({super.key, required this.node, required this.onTap});

  final PathNode node;
  final VoidCallback onTap;

  /// Size of the current circle; the others are [smallSize].
  static const double bigSize = 96;
  static const double smallSize = 72;

  /// Size of this circle.
  double get size {
    if (node.state == PathNodeState.current) {
      return bigSize;
    }
    return smallSize;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // ── Colour, shadow and label for each state ──
    Color fill;
    String label;
    List<BoxShadow> shadows;
    switch (node.state) {
      case PathNodeState.finished:
        fill = colors.leaf;
        label = 'Story ${node.number}, finished';
        shadows = [_bottomShadow(fill)];
      case PathNodeState.current:
        fill = colors.primary;
        label = 'Story ${node.number}, tap to play';
        shadows = [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 10,
          ),
          _bottomShadow(fill),
        ];
      case PathNodeState.locked:
        fill = colors.border;
        label = 'Story ${node.number}, locked';
        shadows = [_bottomShadow(fill)];
    }

    // ── Number or lock inside the circle ──
    Widget inside;
    if (node.state == PathNodeState.locked) {
      inside = Icon(Icons.lock_outline, size: 32, color: colors.inkMuted);
    } else {
      inside = Text(
        '${node.number}',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: Colors.white,
          fontSize: node.state == PathNodeState.current ? 40 : 30,
        ),
      );
    }

    // ── Round button ──
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: shadows,
          ),
          child: inside,
        ),
      ),
    );
  }

  BoxShadow _bottomShadow(Color color) {
    return BoxShadow(
      color: Color.lerp(color, Colors.black, 0.25)!,
      offset: const Offset(0, 6),
    );
  }
}
