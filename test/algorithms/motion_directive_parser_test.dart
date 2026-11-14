import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/motion_directive_parser.dart';
import 'package:kidslearn_ai/data/models/motion_directive.dart';

const pageText = 'Mango rolls his red ball. "Catch it!" he says.';

void main() {
  // ── A correct answer is kept ──
  test('a valid motion object is kept as it is', () {
    final motion = MotionDirectiveParser.parse({
      'camera': 'pan_left',
      'focus': 'right',
      'character_action': 'hop',
      'effect': 'rain',
      'mood': 'surprised',
      'cue_word': 'ball',
    }, pageText);

    expect(motion.camera, 'pan_left');
    expect(motion.focus, 'right');
    expect(motion.characterAction, 'hop');
    expect(motion.effect, 'rain');
    expect(motion.mood, 'surprised');
    expect(motion.cueWord, 'ball');
  });

  // ── Missing or wrong fields get safe defaults from the mood ──
  test('missing fields are filled from the mood', () {
    final motion = MotionDirectiveParser.parse({'mood': 'sad'}, pageText);

    expect(motion.mood, 'sad');
    expect(motion.camera, 'slow_zoom_out');
    expect(motion.characterAction, 'idle_breathe');
    expect(motion.focus, 'center');
    expect(motion.effect, 'none');
    expect(motion.cueWord, '');
  });

  test('a word outside the vocabulary is replaced, the rest is kept', () {
    final motion = MotionDirectiveParser.parse({
      'camera': 'shake_hard',
      'focus': 'left',
      'character_action': 'explode',
      'effect': 'lightning',
      'mood': 'happy',
      'cue_word': 'ball',
    }, pageText);

    expect(motion.camera, 'slow_zoom_in');
    expect(motion.focus, 'left');
    expect(motion.characterAction, 'bounce');
    expect(motion.effect, 'none');
    expect(motion.mood, 'happy');
  });

  test('an unknown mood becomes calm', () {
    final motion = MotionDirectiveParser.parse({'mood': 'angry'}, pageText);

    expect(motion.toMap(), MotionDirective.calm.toMap());
  });

  test('a wrong type in a field is treated as missing', () {
    final motion = MotionDirectiveParser.parse({
      'camera': 5,
      'focus': ['left'],
      'mood': 'curious',
      'cue_word': 42,
    }, pageText);

    expect(motion.camera, 'pan_right');
    expect(motion.focus, 'center');
    expect(motion.cueWord, '');
  });

  // ── Bad model output never throws ──
  test('anything that is not an object gives the calm defaults', () {
    for (final bad in [null, 'zoom', 7, true, <String>[]]) {
      final motion = MotionDirectiveParser.parse(bad, pageText);

      expect(motion.toMap(), MotionDirective.calm.toMap());
    }
  });

  // ── The cue word must be a word of this page ──
  test('the cue word is matched without case or punctuation', () {
    final motion = MotionDirectiveParser.parse({
      'mood': 'happy',
      'cue_word': 'Catch!',
    }, pageText);

    expect(motion.cueWord, 'catch');
  });

  test('a cue word that is not on the page is dropped', () {
    final motion = MotionDirectiveParser.parse({
      'mood': 'happy',
      'cue_word': 'dragon',
    }, pageText);

    expect(motion.cueWord, '');
  });

  // ── JSON text from SQLite ──
  test('a saved directive comes back the same', () {
    final saved = MotionDirectiveParser.parse({
      'camera': 'pan_up',
      'focus': 'top',
      'character_action': 'sway',
      'effect': 'stars_twinkle',
      'mood': 'sleepy',
      'cue_word': 'ball',
    }, pageText);

    final read = MotionDirectiveParser.parseJson(
      jsonEncode(saved.toMap()),
      pageText,
    );

    expect(read.toMap(), saved.toMap());
  });

  test('missing or broken JSON text gives the calm defaults', () {
    for (final bad in [null, '', '{camera: pan', '[1, 2]', '"text"']) {
      final motion = MotionDirectiveParser.parseJson(bad, pageText);

      expect(motion.toMap(), MotionDirective.calm.toMap());
    }
  });

  // ── The model's one-line motion (decision 033) ──
  test('a motion line is split into the six fields in order', () {
    final motion = MotionDirectiveParser.parse(
      'pan_left right hop rain surprised ball',
      pageText,
    );

    expect(motion.camera, 'pan_left');
    expect(motion.focus, 'right');
    expect(motion.characterAction, 'hop');
    expect(motion.effect, 'rain');
    expect(motion.mood, 'surprised');
    expect(motion.cueWord, 'ball');
  });

  test('a dash means no cue word; extra spaces do not matter', () {
    final motion = MotionDirectiveParser.parse(
      '  slow_zoom_out   center sway  none sleepy - ',
      pageText,
    );

    expect(motion.camera, 'slow_zoom_out');
    expect(motion.mood, 'sleepy');
    expect(motion.cueWord, '');
  });

  test('a short line keeps its parts and fills the rest with defaults', () {
    final motion = MotionDirectiveParser.parse('pan_up top', pageText);

    expect(motion.camera, 'pan_up');
    expect(motion.focus, 'top');
    expect(motion.mood, 'calm');
    expect(motion.characterAction, 'idle_breathe');
  });

  test('extra words after the cue word are ignored', () {
    final motion = MotionDirectiveParser.parse(
      'static center nod none curious ball and more words',
      pageText,
    );

    expect(motion.mood, 'curious');
    expect(motion.cueWord, 'ball');
  });

  // ── Every mood has defaults inside the vocabulary ──
  test('the defaults of every mood use only vocabulary words', () {
    for (final mood in MotionDirective.moods) {
      final motion = MotionDirectiveParser.defaultsFor(mood);

      expect(MotionDirective.cameras, contains(motion.camera));
      expect(MotionDirective.focuses, contains(motion.focus));
      expect(
        MotionDirective.characterActions,
        contains(motion.characterAction),
      );
      expect(MotionDirective.effects, contains(motion.effect));
      expect(motion.mood, mood);
    }
  });
}
