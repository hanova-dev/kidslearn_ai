import 'package:flutter/material.dart';

/// Asks a yes/no question; returns true only when the parent taps [yesLabel].
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String yesLabel,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(yesLabel),
        ),
      ],
    ),
  );
  return answer ?? false;
}
