import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';

/// A short message for the viewer, with Try again or Back to my stories.
class ViewerMessage extends StatelessWidget {
  const ViewerMessage({super.key, required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (onRetry != null)
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          if (onRetry == null)
            FilledButton(
              onPressed: () => context.go(AppRoutes.pathMap),
              child: const Text('Back to my stories'),
            ),
        ],
      ),
    );
  }
}
