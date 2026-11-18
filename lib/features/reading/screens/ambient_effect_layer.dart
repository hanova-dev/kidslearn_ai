import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../algorithms/ambient_effect.dart';
import '../../../algorithms/frame_drop_detector.dart';
import '../../../app/app_colors.dart';
import 'ambient_effect_painter.dart';

/// Runs the clock of one ambient effect and paints it over the picture (FR-MOTION-09).
class AmbientEffectLayer extends StatefulWidget {
  const AmbientEffectLayer({
    super.key,
    required this.effect,
    required this.onTooSlow,
    this.running = true,
  });

  final AmbientEffect effect;

  /// Called once if the phone draws too many slow frames while the effect runs (FR-MOTION-12).
  final VoidCallback onTooSlow;

  /// False freezes the particles where they are (Reader Mode while reading).
  final bool running;

  @override
  State<AmbientEffectLayer> createState() => _AmbientEffectLayerState();
}

class _AmbientEffectLayerState extends State<AmbientEffectLayer>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _clock = ValueNotifier<int>(0);
  late final Ticker _ticker;
  final FrameDropDetector _frames = FrameDropDetector();
  int _frozenMs = 0;

  // ── Start the clock: every frame tells the painter the new time ──
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _clock.value = _frozenMs + elapsed.inMilliseconds;
    });
    if (widget.running) {
      _ticker.start();
    }
    SchedulerBinding.instance.addTimingsCallback(_checkFrames);
  }

  // ── Watch the real frame times while the effect moves (FR-MOTION-12) ──
  void _checkFrames(List<FrameTiming> timings) {
    if (!_ticker.isActive) {
      return;
    }
    for (final timing in timings) {
      final drawTime = timing.buildDuration + timing.rasterDuration;
      if (_frames.addFrame(drawTime.inMilliseconds)) {
        widget.onTooSlow();
      }
    }
  }

  // ── Freeze or go on from the same moment ──
  @override
  void didUpdateWidget(AmbientEffectLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.running && _ticker.isActive) {
      _ticker.stop();
      _frozenMs = _clock.value;
    }
    if (widget.running && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_checkFrames);
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  // ── Paint on its own layer; touches pass through to the picture ──
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: AmbientEffectPainter(
            effect: widget.effect,
            clock: _clock,
            colors: AppColors.of(context),
          ),
        ),
      ),
    );
  }
}
