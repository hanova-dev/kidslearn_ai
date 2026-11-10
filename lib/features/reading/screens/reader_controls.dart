import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../controllers/reader_step.dart';
import 'page_dots.dart';

/// The bottom of Reader Mode: mic, stop, "checking", or Read again and Next page (designs p18–p20).
class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.step,
    required this.pageIndex,
    required this.pageCount,
    required this.onMic,
    required this.onStop,
    required this.onReadAgain,
    required this.onNext,
  });

  final ReaderStep step;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onMic;
  final VoidCallback onStop;
  final VoidCallback onReadAgain;
  final VoidCallback onNext;

  /// Size of the round mic and stop buttons.
  static const double micSize = 88;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final labelStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: colors.ink);

    // ── Listening: sound bars and the stop button (p19) ──
    if (step == ReaderStep.listening) {
      return Column(
        children: [
          Icon(Icons.graphic_eq_rounded, color: colors.primary, size: 56),
          Text("I'm listening…", style: labelStyle),
          const SizedBox(height: 12),
          _roundButton(
            tooltip: 'Stop',
            icon: Icons.stop_rounded,
            background: colors.surface,
            foreground: colors.primary,
            onPressed: onStop,
          ),
        ],
      );
    }

    // ── Checking: the transcript is on its way ──
    if (step == ReaderStep.checking) {
      return Column(
        children: [
          const SizedBox(
            height: micSize,
            child: Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 12),
          Text('Checking your reading…', style: labelStyle),
        ],
      );
    }

    // ── Checked: page dots, Read again and Next page (p20) ──
    if (step == ReaderStep.checked) {
      final isLast = pageIndex == pageCount - 1;
      var nextLabel = 'Next page';
      if (isLast) {
        nextLabel = 'The end';
      }
      return Column(
        children: [
          PageDots(pageIndex: pageIndex, pageCount: pageCount),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.ink,
                      side: BorderSide(color: colors.border, width: 2),
                    ),
                    onPressed: onReadAgain,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Read again'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.sunshine,
                      foregroundColor: AppColors.day.ink,
                    ),
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(nextLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ── Ready (or starting): the mic button (p18) ──
    final isStarting = step == ReaderStep.starting;
    var label = 'Tap and read';
    if (isStarting) {
      label = 'Getting ready…';
    }
    return Column(
      children: [
        _roundButton(
          tooltip: 'Read aloud',
          icon: Icons.mic_rounded,
          background: colors.primary,
          foreground: Colors.white,
          onPressed: isStarting ? null : onMic,
        ),
        const SizedBox(height: 12),
        Text(label, style: labelStyle),
      ],
    );
  }

  Widget _roundButton({
    required String tooltip,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: micSize,
      height: micSize,
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: foreground, width: 3),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 44),
      ),
    );
  }
}
