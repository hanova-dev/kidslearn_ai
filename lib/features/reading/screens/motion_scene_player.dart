import 'package:flutter/material.dart';

import '../../../algorithms/ambient_effect.dart';
import '../../../algorithms/motion_timeline.dart';
import '../../../algorithms/scene_choreographer.dart';
import '../../../data/models/motion_directive.dart';
import '../../../policy/motion_profile.dart';
import 'ambient_effect_layer.dart';

/// Moves only the picture of a page and draws its ambient effect; the text is never inside it (FR-MOTION-04, 05, 09).
class MotionScenePlayer extends StatefulWidget {
  const MotionScenePlayer({
    super.key,
    required this.directive,
    required this.profile,
    required this.child,
    this.settled = false,
    this.cueHeard = false,
  });

  final MotionDirective directive;
  final MotionProfile profile;

  /// The picture to move.
  final Widget child;

  /// True stops the camera where it is and keeps it still (Reader Mode while reading).
  final bool settled;

  /// Becomes true when the voice says the page's cue word; the camera then eases to the focus point.
  final bool cueHeard;

  @override
  State<MotionScenePlayer> createState() => _MotionScenePlayerState();
}

class _MotionScenePlayerState extends State<MotionScenePlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  late final AmbientEffect _effect;
  MotionTimeline _timeline = MotionTimeline.still;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this);
    _effect = AmbientEffect(
      widget.directive.effect,
      count: widget.profile.effectCount,
    );
  }

  // ── Make the timeline (needs the text direction and "Remove animations") ──
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _timeline = const SceneChoreographer().timelineFor(
      widget.directive,
      widget.profile,
      rightToLeft: Directionality.of(context) == TextDirection.rtl,
      reduceMotion: _reduceMotion,
    );
    _clock.duration = Duration(milliseconds: _timeline.durationMs);
    if (_timeline.isStill || widget.settled) {
      _clock.stop();
    } else {
      _clock.forward();
    }
  }

  // ── Reader Mode starts the microphone: stop. The cue word is spoken: ease to the focus point ──
  @override
  void didUpdateWidget(MotionScenePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settled && !oldWidget.settled) {
      _clock.stop();
    }
    if (widget.cueHeard && !oldWidget.cueHeard && !widget.settled) {
      _easeToFocus();
    }
  }

  // ── The cue word: a new short timeline from where the camera is now (FR-MOTION-07) ──
  void _easeToFocus() {
    final now = _timeline.cameraAt(_currentMs());
    _timeline = const SceneChoreographer().cueTimelineFor(
      now,
      widget.directive,
      widget.profile,
      reduceMotion: _reduceMotion,
    );
    if (_timeline.isStill) {
      return;
    }
    _clock.duration = Duration(milliseconds: _timeline.durationMs);
    _clock.forward(from: 0);
  }

  int _currentMs() {
    return (_clock.value * _timeline.durationMs).round();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  // ── Draw the picture at the camera of this moment, and the effect on top ──
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _clock,
              child: widget.child,
              builder: (context, picture) {
                final camera = _timeline.cameraAt(_currentMs());
                return FractionalTranslation(
                  translation: Offset(camera.dx, camera.dy),
                  child: Transform.scale(scale: camera.scale, child: picture),
                );
              },
            ),
            if (!_effect.isNone && !_reduceMotion)
              Positioned.fill(
                child: AmbientEffectLayer(
                  effect: _effect,
                  running: !widget.settled,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
