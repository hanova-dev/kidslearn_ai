import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// A 3 × 4 number pad: digits 0–9, delete and OK (parental gate).
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onDone,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(context, ['1', '2', '3']),
        _buildRow(context, ['4', '5', '6']),
        _buildRow(context, ['7', '8', '9']),
        Row(
          children: [
            _PadKey(
              key: const Key('key-delete'),
              onTap: onDelete,
              child: const Icon(Icons.backspace_outlined),
            ),
            _digitKey(context, '0'),
            _PadKey(
              key: const Key('key-ok'),
              onTap: onDone,
              isMain: true,
              child: const Text('OK'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    final keys = <Widget>[];
    for (final digit in digits) {
      keys.add(_digitKey(context, digit));
    }
    return Row(children: keys);
  }

  Widget _digitKey(BuildContext context, String digit) {
    return _PadKey(
      key: Key('key-$digit'),
      onTap: () => onDigit(digit),
      child: Text(digit),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    super.key,
    required this.onTap,
    required this.child,
    this.isMain = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.parentSpacing / 2),
        child: Material(
          color: isMain ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              height: AppSizes.readerTouchTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: isMain
                      ? Theme.of(context).colorScheme.onPrimary
                      : colors.ink,
                ),
                child: IconTheme(
                  data: IconThemeData(color: colors.ink),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
