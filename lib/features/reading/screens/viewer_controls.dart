import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/round_icon_button.dart';

/// Page dots plus Previous and Next buttons; on the last page Next becomes "The end" (design p13).
class ViewerControls extends StatelessWidget {
  const ViewerControls({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int pageIndex;
  final int pageCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Size of the big Next button.
  static const double nextSize = 88;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isFirst = pageIndex == 0;
    final isLast = pageIndex == pageCount - 1;

    // ── Page dots (the current page is a long pill) ──
    final dots = <Widget>[];
    for (var i = 0; i < pageCount; i++) {
      final isCurrent = i == pageIndex;
      dots.add(
        Container(
          width: isCurrent ? 32 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isCurrent ? colors.primary : colors.border,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    // ── Next, or "The end" on the last page ──
    var nextColor = colors.primary;
    var nextIcon = Icons.arrow_forward_rounded;
    var nextTooltip = 'Next page';
    if (isLast) {
      nextColor = colors.leaf;
      nextIcon = Icons.check_rounded;
      nextTooltip = 'The end';
    }

    return Column(
      children: [
        Semantics(
          label: 'Page ${pageIndex + 1} of $pageCount',
          child: Row(mainAxisSize: MainAxisSize.min, children: dots),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Previous (hidden on the first page, space kept) ──
            Visibility(
              visible: !isFirst,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: RoundIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Previous page',
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: nextSize,
              height: nextSize,
              child: IconButton(
                tooltip: nextTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: nextColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: onNext,
                icon: Icon(nextIcon, size: 44),
              ),
            ),
            const SizedBox(width: 24 + AppSizes.listenerTouchTarget),
          ],
        ),
      ],
    );
  }
}
