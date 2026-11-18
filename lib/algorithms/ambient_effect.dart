import 'dart:math';

/// Where one effect particle is at a moment; x and y are fractions of the picture (0 to 1).
class ParticleState {
  const ParticleState({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.turn,
  });

  final double x;
  final double y;

  /// 0.5 to 1.0; the painter multiplies its own base size by this.
  final double size;

  /// 0 (invisible) to 1 (fully visible).
  final double opacity;

  /// -1 to 1; a leaf's tilt or a butterfly's wing beat.
  final double turn;
}

/// The seeds of one particle: picked once, then fixed for the whole page.
class _Seed {
  _Seed(Random random)
    : startX = random.nextDouble(),
      startY = random.nextDouble(),
      phase = random.nextDouble(),
      size = 0.5 + random.nextDouble() * 0.5;

  final double startX;
  final double startY;
  final double phase;
  final double size;
}

/// Computes the gentle ambient effect of a page from its effect word (M11, FR-MOTION-09).
class AmbientEffect {
  AmbientEffect(this.name, {required int count, int seed = 7})
    : _seeds = _makeSeeds(count, seed);

  final String name;
  final List<_Seed> _seeds;

  /// The same [seed] always gives the same particles, so a page looks the same every time.
  static List<_Seed> _makeSeeds(int count, int seed) {
    final random = Random(seed);
    final seeds = <_Seed>[];
    for (var i = 0; i < count; i++) {
      seeds.add(_Seed(random));
    }
    return seeds;
  }

  // ── How long one particle takes for one cycle, in milliseconds (the effect tunables) ──
  static const Map<String, int> cycleMs = {
    'falling_leaves': 9000,
    'rain': 1600,
    'snow': 10000,
    'stars_twinkle': 3000,
    'sparkles': 2400,
    'bubbles': 8000,
    'butterflies': 12000,
  };

  /// A butterfly beats its wings 1.5 times a second (below 3 per second, NFR-USE-06).
  static const double wingBeatsPerSecond = 1.5;

  /// True for "none" and for any word we cannot draw: the page shows no effect.
  bool get isNone => !cycleMs.containsKey(name) || _seeds.isEmpty;

  // ── Every particle at one moment ──
  /// The particles at [ms] milliseconds after the page opened; empty when [isNone].
  List<ParticleState> statesAt(int ms) {
    if (isNone) {
      return const [];
    }
    final states = <ParticleState>[];
    for (final seed in _seeds) {
      states.add(_stateOf(seed, ms));
    }
    return states;
  }

  // ── One particle: where it is in its cycle, then the move of its kind ──
  ParticleState _stateOf(_Seed seed, int ms) {
    final progress = (ms / cycleMs[name]! + seed.phase) % 1.0;
    final wave = sin(2 * pi * (progress * 2 + seed.phase));
    switch (name) {
      case 'falling_leaves':
        return _move(
          seed,
          seed.startX + 0.05 * wave,
          _down(progress),
          0.9,
          wave,
        );
      case 'rain':
        return _move(
          seed,
          seed.startX - 0.05 * progress,
          _down(progress),
          0.5,
          0,
        );
      case 'snow':
        return _move(seed, seed.startX + 0.03 * wave, _down(progress), 0.9, 0);
      case 'bubbles':
        return _move(
          seed,
          seed.startX + 0.03 * wave,
          1 - _down(progress),
          0.7,
          0,
        );
      case 'stars_twinkle':
      case 'sparkles':
        final glow = 0.5 + 0.5 * sin(2 * pi * progress);
        return _move(seed, seed.startX, seed.startY * 0.6, 0.3 + 0.6 * glow, 0);
      default:
        return _butterfly(seed, progress, ms);
    }
  }

  // ── A butterfly drifts in a slow loop and beats its wings ──
  ParticleState _butterfly(_Seed seed, double progress, int ms) {
    final x = 0.1 + seed.startX * 0.8 + 0.08 * sin(2 * pi * progress);
    final y = 0.15 + seed.startY * 0.6 + 0.05 * sin(4 * pi * progress);
    final beat = sin(2 * pi * (ms / 1000 * wingBeatsPerSecond + seed.phase));
    return _move(seed, x, y, 0.9, beat);
  }

  /// From just above the top (-0.1) to just below the bottom (1.1).
  double _down(double progress) {
    return -0.1 + 1.2 * progress;
  }

  ParticleState _move(
    _Seed seed,
    double x,
    double y,
    double opacity,
    double turn,
  ) {
    return ParticleState(
      x: x,
      y: y,
      size: seed.size,
      opacity: opacity,
      turn: turn,
    );
  }
}
