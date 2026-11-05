import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';
import '../controllers/path_node.dart';
import 'path_node_button.dart';
import 'path_road.dart';

/// The scrolling path: road, story circles, the buddy and "Tap to play!" next to the current story.
class PathMapView extends StatelessWidget {
  const PathMapView({
    super.key,
    required this.nodes,
    required this.buddy,
    required this.onTapNode,
  });

  final List<PathNode> nodes;
  final Buddy buddy;
  final void Function(PathNode node) onTapNode;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        var height = PathLayout.heightFor(nodes.length);
        if (height < constraints.maxHeight) {
          height = constraints.maxHeight;
        }

        // ── Centre of every circle ──
        final centres = <Offset>[];
        for (var i = 0; i < nodes.length; i++) {
          centres.add(PathLayout.centreOf(i, width, height));
        }

        // ── Road, then circles on top ──
        final layers = <Widget>[
          CustomPaint(
            size: Size(width, height),
            painter: PathRoadPainter(centres: centres, colors: colors),
          ),
        ];
        for (var i = 0; i < nodes.length; i++) {
          final button = PathNodeButton(
            node: nodes[i],
            onTap: () => onTapNode(nodes[i]),
          );
          final half = button.size / 2;
          layers.add(
            Positioned(
              left: centres[i].dx - half,
              top: centres[i].dy - half,
              child: button,
            ),
          );
          if (nodes[i].state == PathNodeState.current) {
            layers.addAll(_currentMarkers(context, centres[i], width));
          }
        }

        // ── Scroll starts at the bottom, where story 1 is ──
        return SingleChildScrollView(
          reverse: true,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(children: layers),
          ),
        );
      },
    );
  }

  // ── Buddy and "Tap to play!" bubble beside the current circle ──
  List<Widget> _currentMarkers(
    BuildContext context,
    Offset centre,
    double width,
  ) {
    final colors = AppColors.of(context);
    const buddySize = 72.0;
    var buddyLeft = centre.dx + 60;
    if (centre.dx > width / 2) {
      buddyLeft = centre.dx - 60 - buddySize;
    }
    return [
      Positioned(
        left: buddyLeft,
        top: centre.dy - buddySize / 2 + 16,
        child: BuddyFace(buddy: buddy, size: buddySize),
      ),
      Positioned(
        left: centre.dx - 80,
        width: 160,
        top: centre.dy - 112,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 2),
            ),
            child: Text(
              'Tap to play!',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: colors.ink),
            ),
          ),
        ),
      ),
    ];
  }
}
