import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/parent_nav_bar.dart';
import '../../children/controllers/children_provider.dart';
import '../controllers/library_item.dart';
import '../controllers/story_library_provider.dart';
import 'library_story_card.dart';

/// Story library: every story as a card, filtered by child (design p9, decision 023).
class StoryLibraryScreen extends ConsumerStatefulWidget {
  const StoryLibraryScreen({super.key});

  @override
  ConsumerState<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends ConsumerState<StoryLibraryScreen> {
  /// The child chip that is selected; null means "All".
  String? _childId;

  // ── Open a story: still being made → generating screen, else preview ──
  void _open(LibraryItem item) {
    if (item.isInProgress) {
      context.go(AppRoutes.storyGenerating);
      return;
    }
    context.go(AppRoutes.storyPreviewOf(item.story.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final children = ref.watch(childrenProvider).value ?? [];
    final library = ref.watch(storyLibraryProvider);

    return Scaffold(
      bottomNavigationBar: const ParentNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Story library', style: textTheme.headlineSmall),
              const SizedBox(height: 16),

              // ── Child filter chips ──
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoicePill(
                    label: 'All',
                    isSelected: _childId == null,
                    onTap: () => setState(() => _childId = null),
                  ),
                  for (final child in children)
                    ChoicePill(
                      label: child.name,
                      isSelected: _childId == child.id,
                      onTap: () => setState(() => _childId = child.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Story cards ──
              Expanded(
                child: library.when(
                  skipLoadingOnReload: true,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _LoadError(
                    onRetry: () => ref.invalidate(storyLibraryProvider),
                  ),
                  data: (items) => _StoryGrid(
                    items: _filter(items),
                    emptyText: _childId == null
                        ? 'No stories yet. Go to Home and tap "Create a story".'
                        : 'No stories for this reader yet.',
                    onOpen: _open,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Keep only the selected child's stories ──
  List<LibraryItem> _filter(List<LibraryItem> items) {
    if (_childId == null) {
      return items;
    }
    final kept = <LibraryItem>[];
    for (final item in items) {
      if (item.story.childId == _childId) {
        kept.add(item);
      }
    }
    return kept;
  }
}

class _StoryGrid extends StatelessWidget {
  const _StoryGrid({
    required this.items,
    required this.emptyText,
    required this.onOpen,
  });

  final List<LibraryItem> items;
  final String emptyText;
  final void Function(LibraryItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(emptyText, style: Theme.of(context).textTheme.bodyLarge);
    }
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 236,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return LibraryStoryCard(item: item, onTap: () => onOpen(item));
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Could not load your stories.'),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
