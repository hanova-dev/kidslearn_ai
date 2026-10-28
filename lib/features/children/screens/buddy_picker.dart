import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/buddies.dart';
import '../../../core/widgets/buddy_face.dart';

/// Row of the 4 buddy faces; the chosen one gets a primary-colour ring.
class BuddyPicker extends StatelessWidget {
  const BuddyPicker({super.key, required this.selected, required this.onPick});

  final Buddy? selected;
  final ValueChanged<Buddy> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final faces = <Widget>[];
    for (final buddy in Buddies.all) {
      final isSelected = buddy.id == selected?.id;
      faces.add(
        GestureDetector(
          onTap: () => onPick(buddy),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: BuddyFace(buddy: buddy, size: 58),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: faces,
    );
  }
}
