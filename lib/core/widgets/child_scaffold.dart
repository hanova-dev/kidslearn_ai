import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../constants/app_sizes.dart';
import 'child_home_button.dart';
import 'round_icon_button.dart';
import 'scenery_background.dart';

/// The frame of a child screen: Back always top-left, Home always bottom-centre (SRS 10.9, D5, FR-HCI-04).
///
/// A screen fills only the top-middle and top-right slots and the [body]; it cannot move Back or Home.
class ChildScaffold extends StatelessWidget {
  const ChildScaffold({
    super.key,
    required this.onBack,
    required this.body,
    this.topCentre,
    this.topRight,
    this.scenery = false,
  });

  final VoidCallback onBack;
  final Widget body;

  /// For example the star count on the path map.
  final Widget? topCentre;

  /// For example Read aloud in the story viewer, or the star count in Reader Mode.
  final Widget? topRight;

  /// True paints the sky and hills behind the screen (path map).
  final bool scenery;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // ── Top bar: Back, then the screen's own slots ──
    final topBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            tooltip: 'Back',
            onPressed: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(child: Center(child: topCentre)),
          const SizedBox(width: 12),
          topRight ?? const SizedBox(width: AppSizes.listenerTouchTarget),
        ],
      ),
    );

    Widget content = SafeArea(
      child: Column(
        children: [
          topBar,
          Expanded(child: body),
        ],
      ),
    );
    if (scenery) {
      content = SceneryBackground(child: content);
    }

    // ── Home button (fixed bottom-centre) ──
    return Scaffold(
      backgroundColor: colors.background,
      body: content,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const ChildHomeButton(),
    );
  }
}
