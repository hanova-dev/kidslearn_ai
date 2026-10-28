import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../../../data/models/child_profile.dart';
import '../controllers/active_child.dart';
import '../controllers/children_provider.dart';

/// Child space entry: pick who is reading (design p12, FR-AUTH-05).
class WhoIsReadingScreen extends ConsumerWidget {
  const WhoIsReadingScreen({super.key});

  // ── Pick a child ──
  void _pick(BuildContext context, WidgetRef ref, ChildProfile child) {
    ref.read(activeChildProvider.notifier).select(child);
    context.go(AppRoutes.pathMap);
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
              // ── Lumi asks ──
              Row(
                children: [
                  const LumiMascot(size: 56),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        "Who's reading today?",
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Child cards ──
              Expanded(
                child: children.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(childrenProvider),
                      child: const Text(
                        'Something went wrong. Tap to try again.',
                      ),
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'No readers yet. Ask a grown-up to add one.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                      );
                    }
                    final cards = <Widget>[];
                    for (final child in list) {
                      cards.add(
                        _ChildCard(
                          child: child,
                          onTap: () => _pick(context, ref, child),
                        ),
                      );
                    }
                    return ListView(children: cards);
                  },
                ),
              ),

              // ── Grown-ups (the router sends this to the gate) ──
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.parentHome),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Grown-ups'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.onTap});

  final ChildProfile child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.listenerSpacing),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                BuddyFace(
                  buddy: Buddies.byId(child.buddyId),
                  size: AppSizes.listenerTouchTarget + 8,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          fontFamily: AppFonts.fredoka,
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                        ),
                      ),
                      Text(child.ageGroup.title, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
