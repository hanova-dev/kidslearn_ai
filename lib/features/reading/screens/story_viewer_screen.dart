import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/child_home_button.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../services/text_to_speech_service.dart';
import '../controllers/story_viewer_provider.dart';
import 'scene_picture.dart';
import 'viewer_controls.dart';

/// Shows one approved story page by page: picture, sentence, read aloud (design p13, decisions 006, 025).
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  int _page = 0;
  late final TextToSpeechService _voice;

  @override
  void initState() {
    super.initState();
    _voice = ref.read(textToSpeechServiceProvider);
  }

  @override
  void dispose() {
    _voice.stop();
    super.dispose();
  }

  // ── Read this page aloud (FR-TTS-01, FR-TTS-02) ──
  Future<void> _readAloud(StoryViewerData data) async {
    final spoken = await _voice.speak(
      data.scenes[_page].text,
      data.story.language,
    );
    if (!spoken && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This phone has no voice for this language. '
            'A grown-up can add one in Settings, Text-to-speech.',
          ),
        ),
      );
    }
  }

  // ── Turn the page; after the last page go back to the path ──
  void _goTo(int page) {
    _voice.stop();
    setState(() => _page = page);
  }

  void _next(StoryViewerData data) {
    if (_page < data.scenes.length - 1) {
      _goTo(_page + 1);
      return;
    }
    _voice.stop();
    context.go(AppRoutes.pathMap);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final viewer = ref.watch(storyViewerProvider(widget.storyId));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: viewer.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _ViewerMessage(
            text: 'Could not open this story.',
            onRetry: () => ref.invalidate(storyViewerProvider(widget.storyId)),
          ),
          data: (data) {
            if (data == null) {
              return const _ViewerMessage(text: 'This story is not ready yet.');
            }
            return _buildPage(data);
          },
        ),
      ),

      // ── Home button (fixed bottom-centre, SRS 10.9) ──
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const ChildHomeButton(),
    );
  }

  Widget _buildPage(StoryViewerData data) {
    final colors = AppColors.of(context);
    final scene = data.scenes[_page];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // ── Back and Read aloud ──
          Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back_ios_new,
                tooltip: 'Back',
                onPressed: () => context.go(AppRoutes.pathMap),
              ),
              const Spacer(),
              RoundIconButton(
                icon: Icons.volume_up_rounded,
                tooltip: 'Read aloud',
                onPressed: () => _readAloud(data),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Scene picture (or scenery if it is missing) ──
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border, width: 2),
            ),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: ScenePicture(path: scene.imagePath),
            ),
          ),
          const SizedBox(height: 24),

          // ── Sentence in Andika ──
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  scene.text,
                  style: TextStyle(
                    fontFamily: AppFonts.andika,
                    fontSize: 30,
                    height: 1.4,
                    color: colors.ink,
                  ),
                ),
              ),
            ),
          ),

          ViewerControls(
            pageIndex: _page,
            pageCount: data.scenes.length,
            onPrevious: () => _goTo(_page - 1),
            onNext: () => _next(data),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

/// A short message with an optional Try again button.
class _ViewerMessage extends StatelessWidget {
  const _ViewerMessage({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (onRetry != null)
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          if (onRetry == null)
            FilledButton(
              onPressed: () => context.go(AppRoutes.pathMap),
              child: const Text('Back to my stories'),
            ),
        ],
      ),
    );
  }
}
