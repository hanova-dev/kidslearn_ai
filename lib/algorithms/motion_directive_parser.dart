import 'dart:convert';

import '../data/models/motion_directive.dart';
import 'word_aligner.dart';

/// Turns the model's (or SQLite's) motion JSON into a safe [MotionDirective]; never throws (M11, decision 033).
class MotionDirectiveParser {
  // ── Safe defaults for each mood ──
  /// The moves that fit [mood]; an unknown mood gives [MotionDirective.calm].
  static MotionDirective defaultsFor(String mood) {
    var camera = 'static';
    var action = 'idle_breathe';
    if (mood == 'happy') {
      camera = 'slow_zoom_in';
      action = 'bounce';
    } else if (mood == 'sad') {
      camera = 'slow_zoom_out';
    } else if (mood == 'surprised') {
      camera = 'slow_zoom_in';
      action = 'hop';
    } else if (mood == 'curious') {
      camera = 'pan_right';
      action = 'nod';
    } else if (mood == 'sleepy') {
      camera = 'slow_zoom_out';
      action = 'sway';
    } else if (mood != 'calm') {
      return MotionDirective.calm;
    }
    return MotionDirective(
      camera: camera,
      focus: 'center',
      characterAction: action,
      effect: 'none',
      mood: mood,
      cueWord: '',
    );
  }

  /// The order of the six parts in the model's motion line.
  static const List<String> lineOrder = [
    'camera',
    'focus',
    'character_action',
    'effect',
    'mood',
    'cue_word',
  ];

  // ── The model's one-line motion, e.g. "pan_left right hop rain surprised ball" ──
  /// Splits [line] at spaces and gives each part its key; missing parts are left out.
  static Map<String, String> fieldsOfLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    final fields = <String, String>{};
    for (var i = 0; i < parts.length && i < lineOrder.length; i++) {
      fields[lineOrder[i]] = parts[i];
    }
    return fields;
  }

  // ── Check every field against the vocabulary ──
  /// [raw] is the motion line or a decoded motion object; [pageText] is the page, for checking the cue word.
  static MotionDirective parse(Object? raw, String pageText) {
    if (raw is String) {
      raw = fieldsOfLine(raw);
    }
    if (raw is! Map) {
      return MotionDirective.calm;
    }
    final mood = _pick(raw['mood'], MotionDirective.moods, 'calm');
    final defaults = defaultsFor(mood);
    return MotionDirective(
      camera: _pick(raw['camera'], MotionDirective.cameras, defaults.camera),
      focus: _pick(raw['focus'], MotionDirective.focuses, defaults.focus),
      characterAction: _pick(
        raw['character_action'],
        MotionDirective.characterActions,
        defaults.characterAction,
      ),
      effect: _pick(raw['effect'], MotionDirective.effects, defaults.effect),
      mood: defaults.mood,
      cueWord: _cueWordOf(raw['cue_word'], pageText),
    );
  }

  // ── Read the text saved in scenes.motion_json ──
  /// Missing or broken JSON gives [MotionDirective.calm].
  static MotionDirective parseJson(String? text, String pageText) {
    if (text == null || text.isEmpty) {
      return MotionDirective.calm;
    }
    try {
      return parse(jsonDecode(text), pageText);
    } on FormatException {
      return MotionDirective.calm;
    }
  }

  /// [value] if it is one of [allowed], otherwise [fallback].
  static String _pick(Object? value, List<String> allowed, String fallback) {
    if (value is String && allowed.contains(value)) {
      return value;
    }
    return fallback;
  }

  /// The cue word in lower case, or '' if it is not a word of [pageText].
  static String _cueWordOf(Object? value, String pageText) {
    if (value is! String) {
      return '';
    }
    final cue = WordAligner.tokenize(value.toLowerCase());
    if (cue.isEmpty) {
      return '';
    }
    final pageWords = WordAligner.tokenize(pageText.toLowerCase());
    if (pageWords.contains(cue.first)) {
      return cue.first;
    }
    return '';
  }
}
