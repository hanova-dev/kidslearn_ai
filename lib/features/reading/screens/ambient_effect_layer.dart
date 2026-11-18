import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../algorithms/ambient_effect.dart';
import '../../../app/app_colors.dart';
import 'ambient_effect_painter.dart';

/// Runs the clock of one ambient effect and paints it over the picture (FR-MOTION-09).
class AmbientEffectLayer extends StatefulWidget {
  const AmbientEffectLayer({
    super.key,
    required this.effect,
    this.running = true,
  });

  final AmbientEffect effect;

  /// False freezes the particles where they are (Reader Mode while reading).
  final bool running;

  @override
  State<AmbientEffectLayer> createState() => _AmbientEffectLayerState();
}

class _AmbientEffectLayerState extends State<AmbientEffectLayer>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _clock = ValueNotifier<int>(0);
  late final Ticker _ticker;
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
