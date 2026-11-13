import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/errors/speech_failure.dart';
import '../../../core/widgets/child_scaffold.dart';
import '../../../core/widgets/star_count_chip.dart';
import '../../../services/text_to_speech_service.dart';
import '../../children/controllers/active_child.dart';
import '../controllers/reader_step.dart';
import '../controllers/reading_controller.dart';
import '../controllers/sentence_check.dart';
import '../controllers/story_finisher.dart';
import '../controllers/story_viewer_provider.dart';
import 'reader_page.dart';
import 'viewer_message.dart';

/// Reader Mode for ages 5–7: read each sentence aloud, see every word coloured (designs p18–p20, FR-MODE-04, FR-MODE-05).
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  /// The microphone turns itself off after this long (FR-STT-01).
  static const Duration longestReading = Duration(seconds: 45);

  int _page = 0;
  ReaderStep _step = ReaderStep.ready;
  SentenceCheck? _check;
  String? _problem;
  final Map<int, int> _bestStars = {};
  Timer? _autoStop;
  bool _finishing = false;
  late final TextToSpeechService _voice;
  late final ReadingController _reading;

  @override
  void initState() {
    super.initState();
    _voice = ref.read(textToSpeechServiceProvider);
    _reading = ref.read(readingControllerProvider);
  }

  @override
  void dispose() {
    _autoStop?.cancel();
    if (_step == ReaderStep.starting || _step == ReaderStep.listening) {
      _reading.cancel();
    }
    _voice.stop();
    super.dispose();
  }

  /// Stars earned in this story so far: the best reading of every page (decision 009).
  int get _storyStars {
    var total = 0;
    for (final stars in _bestStars.values) {
      total += stars;
    }
    return total;
  }

  // ── Microphone on (FR-STT-01) ──
  Future<void> _startReading(StoryViewerData data) async {
    await _voice.stop();
    setState(() {
      _step = ReaderStep.starting;
      _check = null;
      _problem = null;
    });
    try {
      await _reading.startReading(data.story.language);
    } on SpeechFailure catch (failure) {
      _showProblem(failure.message, data.story.language);
      return;
    }
    if (!mounted) {
      _reading.cancel();
      return;
    }
    setState(() => _step = ReaderStep.listening);
    _autoStop = Timer(longestReading, () => _stopReading(data));
  }

  // ── Microphone off, then colour the words (FR-MODE-05, FR-SCORE-07) ──
  Future<void> _stopReading(StoryViewerData data) async {
    if (_step != ReaderStep.listening) {
      return;
    }
    _autoStop?.cancel();
    setState(() => _step = ReaderStep.checking);
    final language = data.story.language;
    try {
      final check = await _reading.finishReading(
        data.scenes[_page].text,
        language,
      );
      if (!mounted) {
        return;
      }
      final best = _bestStars[_page] ?? 0;
      setState(() {
        _check = check;
        _step = ReaderStep.checked;
        if (check.stars > best) {
          _bestStars[_page] = check.stars;
        }
      });
      _voice.speak(check.feedback, language);
    } on SpeechFailure catch (failure) {
      _showProblem(failure.message, language);
    }
  }

  // ── Nothing heard, no microphone, or the switch to the phone (FR-STT-05) ──
  void _showProblem(String message, String language) {
    if (!mounted) {
      return;
    }
    setState(() {
      _step = ReaderStep.ready;
      _problem = message;
    });
    _voice.speak(message, language);
  }

  void _readAgain() {
    _voice.stop();
    setState(() {
      _step = ReaderStep.ready;
      _check = null;
      _problem = null;
    });
  }

  // ── Next page, or save the reading after the last one (decision 026) ──
  Future<void> _next(StoryViewerData data) async {
    _voice.stop();
    if (_page < data.scenes.length - 1) {
      setState(() {
        _page++;
        _step = ReaderStep.ready;
        _check = null;
        _problem = null;
      });
      return;
    }
    final child = ref.read(activeChildProvider);
    if (_finishing || child == null) {
      return;
    }
    _finishing = true;
    try {
      final result = await ref
          .read(storyFinisherProvider)
          .finish(
            child: child,
            storyId: data.story.id,
            scenes: data.scenes,
            stars: _storyStars,
            now: DateTime.now(),
          );
      ref.read(activeChildProvider.notifier).addStars(result.stars);
      if (mounted) {
        context.go(AppRoutes.storyCompleteOf(data.story.id, result));
      }
    } catch (error) {
      _finishing = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your stars. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = ref.watch(storyViewerProvider(widget.storyId));
    final balance = ref.watch(activeChildProvider)?.starBalance ?? 0;

    // ── Back, the star count and Home: ChildScaffold ──
    return ChildScaffold(
      onBack: () => context.go(AppRoutes.pathMap),
      topRight: StarCountChip(stars: balance + _storyStars),
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
          return ReaderPage(
            scene: data.scenes[_page],
            pageIndex: _page,
            pageCount: data.scenes.length,
            step: _step,
            check: _check,
            problem: _problem,
            onMic: () => _startReading(data),
            onStop: () => _stopReading(data),
            onReadAgain: _readAgain,
            onNext: () => _next(data),
            onReplay: (text) => _voice.speak(text, data.story.language),
          );
        },
      ),
    );
  }
}
