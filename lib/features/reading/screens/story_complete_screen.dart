import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';
import '../../../services/text_to_speech_service.dart';
import '../../children/controllers/active_child.dart';
import '../../children/controllers/active_policy.dart';
import 'celebration_painter.dart';

/// "You did it!" after the last page: words read, stars earned, what next (design p22, FR-MODE-06, D6).
class StoryCompleteScreen extends ConsumerStatefulWidget {
  const StoryCompleteScreen({
    super.key,
    required this.storyId,
    required this.wordsRead,
    required this.stars,
  });

  final String storyId;
  final int wordsRead;
  final int stars;

  @override
  ConsumerState<StoryCompleteScreen> createState() =>
      _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends ConsumerState<StoryCompleteScreen> {
  late final TextToSpeechService _voice;

  // ── Say the cheer once, with the phone's voice ──
  @override
  void initState() {
    super.initState();
    _voice = ref.read(textToSpeechServiceProvider);
    final child = ref.read(activeChildProvider);
    if (child != null) {
      _voice.speak('You did it, ${child.name}!', child.language);
    }
  }

  @override
  void dispose() {
    _voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final child = ref.watch(activeChildProvider);
    var title = 'You did it!';
    var buddy = Buddies.mango;
    if (child != null) {
      title = 'You did it, ${child.name}!';
      buddy = Buddies.byId(child.buddyId);
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // ── Confetti, stars and the buddy ──
              Expanded(
                child: CustomPaint(
                  painter: CelebrationPainter(colors: colors),
                  child: Align(
                    alignment: const Alignment(0, 0.7),
                    child: BuddyFace(buddy: buddy, size: 140),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 20),

              // ── Words read and stars earned ──
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '${widget.wordsRead}',
                      label: 'words read',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      value: '+${widget.stars}',
                      label: 'stars earned',
                      icon: Icons.star_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Next adventure, or the same story again ──
              SizedBox(
                width: double.infinity,
                height: AppSizes.listenerTouchTarget,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.sunshine,
                    foregroundColor: AppColors.day.ink,
                  ),
                  onPressed: () => context.go(AppRoutes.pathMap),
                  child: const Text('Next adventure'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: AppSizes.listenerTouchTarget,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: colors.ink,
                    side: BorderSide(color: colors.border, width: 2),
                  ),
                  onPressed: () => context.go(
                    AppRoutes.openStoryOf(
                      ref.read(activePolicyProvider),
                      widget.storyId,
                    ),
                  ),
                  child: const Text('Read it again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A white box with a big number and a small label, e.g. "18 / words read".
class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colors.border, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: colors.sunshine, size: 30),
              Text(value, style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
