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
import '../../children/controllers/active_child.dart';
import '../controllers/story_finisher.dart';
import '../controllers/story_viewer_provider.dart';
import 'scene_picture.dart';
import 'viewer_controls.dart';
import 'viewer_message.dart';

/// Shows one approved story page by page: picture, sentence, read aloud (design p13, decisions 006, 025, 026).
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  int _page = 0;
  bool _finishing = false;
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
    if (!spoken) {
      _showMessage(
        'This phone has no voice for this language. '
        'A grown-up can add one in Settings, Text-to-speech.',
      );
    }
  }

  void _showMessage(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  // ── Turn the page ──
  void _goTo(int page) {
    _voice.stop();
    setState(() => _page = page);
  }

  // ── After the last page: save the reading, then celebrate (decision 026) ──
  Future<void> _next(StoryViewerData data) async {
    if (_page < data.scenes.length - 1) {
      _goTo(_page + 1);
      return;
    }
    final child = ref.read(activeChildProvider);
    if (_finishing || child == null) {
      return;
    }
    _finishing = true;
    _voice.stop();
    try {
      final result = await ref
          .read(storyFinisherProvider)
          .finish(
            child: child,
            storyId: data.story.id,
            scenes: data.scenes,
            stars: data.scenes.length * StoryFinisher.starsPerPage,
            now: DateTime.now(),
          );
      ref.read(activeChildProvider.notifier).addStars(result.stars);
      if (mounted) {
        context.go(AppRoutes.storyCompleteOf(data.story.id, result));
      }
    } catch (error) {
      _finishing = false;
      _showMessage('Could not save your stars. Please try again.');
    }
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
          error: (error, stack) => ViewerMessage(
            text: 'Could not open this story.',
            onRetry: () => ref.invalidate(storyViewerProvider(widget.storyId)),
          ),
          data: (data) {
            if (data == null) {
              return const ViewerMessage(text: 'This story is not ready yet.');
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
