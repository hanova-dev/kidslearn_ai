import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../data/models/scene.dart';
import '../../../policy/age_experience_policy.dart';
import '../controllers/reader_step.dart';
import '../controllers/sentence_check.dart';
import '../controllers/shown_word.dart';
import 'reader_banner.dart';
import 'reader_controls.dart';
import 'reader_sentence.dart';
import 'scene_picture.dart';
import 'verdict_style.dart';

/// One Reader Mode page under the ChildScaffold top bar: picture, sentence, feedback and the controls (designs p18–p20).
class ReaderPage extends StatelessWidget {
  const ReaderPage({
    super.key,
    required this.scene,
    required this.pageIndex,
    required this.pageCount,
    required this.step,
    required this.check,
    required this.problem,
    required this.onMic,
    required this.onStop,
    required this.onReadAgain,
    required this.onNext,
    required this.onReplay,
  });

  final Scene scene;
  final int pageIndex;
  final int pageCount;
  final ReaderStep step;
  final SentenceCheck? check;
  final String? problem;
  final VoidCallback onMic;
  final VoidCallback onStop;
  final VoidCallback onReadAgain;
  final VoidCallback onNext;

  /// Says a banner's message again with the phone's voice.
  final ValueChanged<String> onReplay;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final results = check?.results ?? const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // ── Scene picture (or scenery if it is missing) ──
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border, width: 2),
            ),
            child: AspectRatio(
              aspectRatio: 1.7,
              child: ScenePicture(path: scene.imagePath),
            ),
          ),
          const SizedBox(height: 20),

          // ── Sentence and feedback ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ReaderSentence(
                    words: ShownWord.listOf(scene.text, results),
                    textSize: const ReaderPolicy().storyTextSize,
                  ),
                  const SizedBox(height: 16),
                  _buildBanner(colors),
                ],
              ),
            ),
          ),

          ReaderControls(
            step: step,
            pageIndex: pageIndex,
            pageCount: pageCount,
            onMic: onMic,
            onStop: onStop,
            onReadAgain: onReadAgain,
            onNext: onNext,
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  // ── A problem, or the result of the reading (SRS 10.8) ──
  Widget _buildBanner(AppColors colors) {
    final message = problem;
    if (message != null) {
      return ReaderBanner(
        color: colors.sky,
        icon: Icons.hearing_rounded,
        text: message,
        onTap: () => onReplay(message),
      );
    }
    final result = check;
    if (result == null) {
      return const SizedBox.shrink();
    }
    final style = VerdictStyle.of(result.overall, colors);
    return ReaderBanner(
      color: style.color,
      icon: style.icon,
      text: result.feedback,
      stars: result.stars,
      onTap: () => onReplay(result.feedback),
    );
  }
}
