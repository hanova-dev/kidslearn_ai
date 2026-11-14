/// How one page moves: camera, where to look, the hero's action, an effect and the mood (M11, decision 033).
class MotionDirective {
  const MotionDirective({
    required this.camera,
    required this.focus,
    required this.characterAction,
    required this.effect,
    required this.mood,
    required this.cueWord,
  });

  // ── The closed vocabulary (the only words the model may use) ──
  static const List<String> cameras = [
    'static',
    'slow_zoom_in',
    'slow_zoom_out',
    'pan_left',
    'pan_right',
    'pan_up',
    'pan_down',
  ];
  static const List<String> focuses = [
    'left',
    'center',
    'right',
    'top',
    'bottom',
  ];
  static const List<String> characterActions = [
    'idle_breathe',
    'bounce',
    'sway',
    'nod',
    'hop',
    'slide_in_left',
    'slide_in_right',
  ];
  static const List<String> effects = [
    'none',
    'falling_leaves',
    'rain',
    'snow',
    'stars_twinkle',
    'sparkles',
    'bubbles',
    'butterflies',
  ];
  static const List<String> moods = [
    'happy',
    'calm',
    'sad',
    'surprised',
    'curious',
    'sleepy',
  ];

  /// The quiet default for old stories and broken answers: no camera move, gentle breathing.
  static const MotionDirective calm = MotionDirective(
    camera: 'static',
    focus: 'center',
    characterAction: 'idle_breathe',
    effect: 'none',
    mood: 'calm',
    cueWord: '',
  );

  final String camera;
  final String focus;
  final String characterAction;
  final String effect;
  final String mood;

  /// A word of the page; the camera eases to [focus] when it is spoken. Empty for none.
  final String cueWord;

  // ── To JSON (saved in scenes.motion_json) ──
  /// The same keys as the model's JSON, e.g. {'camera': 'pan_left', ...}.
  Map<String, Object?> toMap() {
    return {
      'camera': camera,
      'focus': focus,
      'character_action': characterAction,
      'effect': effect,
      'mood': mood,
      'cue_word': cueWord,
    };
  }
}
