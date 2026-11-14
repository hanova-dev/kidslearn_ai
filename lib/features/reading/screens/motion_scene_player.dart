import 'package:flutter/material.dart';

import '../../../algorithms/motion_timeline.dart';
import '../../../algorithms/scene_choreographer.dart';
import '../../../data/models/motion_directive.dart';
import '../../../policy/motion_profile.dart';

/// Moves only the picture of a page along its camera timeline; the text is never inside it (FR-MOTION-04, FR-MOTION-05).
class MotionScenePlayer extends StatefulWidget {
  const MotionScenePlayer({
    super.key,
    required this.directive,
    required this.profile,
    required this.child,
    this.settled = false,
  });

  final MotionDirective directive;
  final MotionProfile profile;

  /// The picture to move.
  final Widget child;

  /// True stops the camera where it is and keeps it still (Reader Mode while reading).
  final bool settled;

  @override
  State<MotionScenePlayer> createState() => _MotionScenePlayerState();
}

class _MotionScenePlayerState extends State<MotionScenePlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  MotionTimeline _timeline = MotionTimeline.still;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this);
  }

  // ── Make the timeline (needs the text direction and "Remove animations") ──
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timeline = const SceneChoreographer().timelineFor(
      widget.directive,
      widget.profile,
      rightToLeft: Directionality.of(context) == TextDirection.rtl,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
    _clock.duration = Duration(milliseconds: _timeline.durationMs);
    if (_timeline.isStill || widget.settled) {
      _clock.stop();
    } else {
      _clock.forward();
    }
  }

  // ── Stop the camera when Reader Mode starts the microphone ──
  @override
  void didUpdateWidget(MotionScenePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settled && !oldWidget.settled) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  // ── Draw the picture at the camera of this moment ──
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _clock,
          child: widget.child,
          builder: (context, picture) {
            final ms = (_clock.value * _timeline.durationMs).round();
            final camera = _timeline.cameraAt(ms);
            return FractionalTranslation(
              translation: Offset(camera.dx, camera.dy),
              child: Transform.scale(scale: camera.scale, child: picture),
            );
          },
        ),
      ),
    );
  }
}
