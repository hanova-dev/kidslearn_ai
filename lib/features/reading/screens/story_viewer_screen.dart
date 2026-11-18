import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/widgets/child_scaffold.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../children/controllers/active_child.dart';
import '../controllers/narration_tracker.dart';
import '../controllers/story_finisher.dart';
import '../controllers/story_viewer_provider.dart';
import 'viewer_controls.dart';
import 'viewer_message.dart';
import 'viewer_page.dart';

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
  bool _mouthOpen = false;
  bool _cueHeard = false;
  late final NarrationTracker _narration;

  @override
  void initState() {
    super.initState();
    _narration = NarrationTracker(
      voice: ref.read(textToSpeechServiceProvider),
      onMouth: (open) => _update(() => _mouthOpen = open),
      onCue: () => _update(() => _cueHeard = true),
    );
  }

  @override
  void dispose() {
    _narration.stop();
    super.dispose();
  }

  void _update(VoidCallback change) {
    if (mounted) {
      setState(change);
    }
  }

  // ── Read this page aloud; Lumi's mouth and the cue word follow the voice (FR-TTS-01, FR-MOTION-07, FR-MOTION-08) ──
  Future<void> _readAloud(StoryViewerData data) async {
    final scene = data.scenes[_page];
    final spoken = await _narration.narrate(
      scene.text,
      data.story.language,
      scene.motion.cueWord,
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
    _narration.stop();
    setState(() {
      _page = page;
      _cueHeard = false;
    });
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
    _narration.stop();
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
    final viewer = ref.watch(storyViewerProvider(widget.storyId));
    final loaded = viewer.value;

    // ── Back, Lumi, Read aloud (once the story is loaded) and Home: ChildScaffold ──
    Widget? readAloud;
    Widget? lumi;
    if (loaded != null) {
      lumi = ExcludeSemantics(
        child: LumiMascot(size: 56, mouthOpen: _mouthOpen),
      );
      readAloud = RoundIconButton(
        icon: Icons.volume_up_rounded,
        tooltip: 'Read aloud',
        onPressed: () => _readAloud(loaded),
      );
    }
    return ChildScaffold(
      onBack: () => context.go(AppRoutes.pathMap),
      topCentre: lumi,
      topRight: readAloud,
      body: viewer.when(
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
    );
  }

  Widget _buildPage(StoryViewerData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: ViewerPage(scene: data.scenes[_page], cueHeard: _cueHeard),
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
