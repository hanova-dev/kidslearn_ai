import 'package:flutter/material.dart';

import '../constants/app_fonts.dart';
import 'choice_pill.dart';

/// English selected and Urdu greyed out "coming soon" (decision 005, designs p4 and p7).
class LanguageChoice extends StatelessWidget {
  const LanguageChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ChoicePill(label: 'English', isSelected: true, onTap: null),
        const SizedBox(width: 8),
        const ChoicePill(
          label: 'اردو',
          isSelected: false,
          onTap: null,
          fontFamily: AppFonts.notoNastaliqUrdu,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Urdu: coming soon',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
