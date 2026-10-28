import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

/// Small grey capital label above a form field, e.g. "EMAIL" (designs p3, p4).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12,
          letterSpacing: 1,
          color: AppColors.of(context).inkMuted,
        ),
      ),
    );
  }
}
