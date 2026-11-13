import 'package:flutter/material.dart';

import '../../../algorithms/verdict.dart';
import '../../../app/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../controllers/shown_word.dart';
import 'verdict_style.dart';

/// The sentence in Andika; after scoring, every word sits on its verdict colour (designs p18–p20, FR-SCORE-07).
class ReaderSentence extends StatelessWidget {
  const ReaderSentence({
    super.key,
    required this.words,
    required this.textSize,
  });

  final List<ShownWord> words;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final word in words) {
      chips.add(_buildWord(context, word));
    }
    return SizedBox(
      width: double.infinity,
      child: Wrap(spacing: 4, runSpacing: 6, children: chips),
    );
  }

  Widget _buildWord(BuildContext context, ShownWord word) {
    final colors = AppColors.of(context);
    final verdict = word.verdict;

    // ── Not scored yet: plain text, same padding so nothing jumps later ──
    if (verdict == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(word.text, style: _textStyle(colors.ink)),
      );
    }

    // ── Scored: tinted box; dotted underline for TRY_AGAIN, dashed for NEAR_MISS ──
    final style = VerdictStyle.of(verdict, colors);
    var textStyle = _textStyle(colors.ink);
    if (verdict != Verdict.correct) {
      var line = TextDecorationStyle.dotted;
      if (verdict == Verdict.nearMiss) {
        line = TextDecorationStyle.dashed;
      }
      textStyle = textStyle.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: style.color,
        decorationStyle: line,
        decorationThickness: 3,
      );
    }
    return Semantics(
      label: '${word.text}, ${style.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Color.lerp(colors.surface, style.color, 0.28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(word.text, style: textStyle),
      ),
    );
  }

  TextStyle _textStyle(Color color) {
    return TextStyle(
      fontFamily: AppFonts.andika,
      fontSize: textSize,
      height: 1.3,
      color: color,
    );
  }
}
