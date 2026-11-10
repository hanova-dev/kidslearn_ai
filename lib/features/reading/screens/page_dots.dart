import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

/// One dot per page; the current page is a long pill (designs p13, p20).
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.pageIndex, required this.pageCount});

  final int pageIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
    return Semantics(
      label: 'Page ${pageIndex + 1} of $pageCount',
      child: Row(mainAxisSize: MainAxisSize.min, children: dots),
    );
  }
}
