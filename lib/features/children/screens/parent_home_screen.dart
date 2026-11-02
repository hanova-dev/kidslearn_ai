import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';
import '../../../data/models/child_profile.dart';
import '../../auth/controllers/parent_unlock.dart';
import '../controllers/children_provider.dart';

/// Simple parent home: the list of readers (design p6, without the chart yet).
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  // ── Profile menu actions ──
  Future<void> _onMenu(BuildContext context, WidgetRef ref, String item) async {
    ref.read(parentUnlockProvider.notifier).lock();
    if (item == 'child-mode') {
      context.go(AppRoutes.whoIsReading);
      return;
    }
    await ref.read(authRepositoryProvider).logOut();
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final children = ref.watch(childrenProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Greeting and profile menu ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hi, grown-up!',
                      style: textTheme.headlineSmall,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Profile menu',
                    icon: const Icon(Icons.person_outline),
                    onSelected: (item) => _onMenu(context, ref, item),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'child-mode',
                        child: Text('Go to child mode'),
                      ),
                      PopupMenuItem(value: 'log-out', child: Text('Log out')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Your readers ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your readers', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    children.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => _LoadError(
                        onRetry: () => ref.invalidate(childrenProvider),
                      ),
                      data: (list) => _ReaderList(children: list),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // ── Actions ──
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.createStory),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Create a story'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.addChild),
                icon: const Icon(Icons.add),
                label: const Text('Add a reader'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderList extends StatelessWidget {
  const _ReaderList({required this.children});

  final List<ChildProfile> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (children.isEmpty) {
      return Text(
        'No readers yet. Add your first reader!',
        style: textTheme.bodyLarge,
      );
    }
    final rows = <Widget>[];
    for (final child in children) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              BuddyFace(buddy: Buddies.byId(child.buddyId), size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: textTheme.titleMedium),
                    Text(
                      '${child.ageGroup.title} · English',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('Could not load your readers.')),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
