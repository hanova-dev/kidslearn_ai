import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../../../core/widgets/scenery_background.dart';

/// First screen: Lumi and the app name on the day or night scenery (design p2).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash stays on screen.
  static const Duration showTime = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ── Move on after a short pause ──
  @override
  void initState() {
    super.initState();
    Future.delayed(SplashScreen.showTime, () {
      if (mounted) {
        context.go(AppRoutes.whoIsReading);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SceneryBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Mascot ──
              const LumiMascot(size: 120),
              const SizedBox(height: 24),

              // ── App name and tagline ──
              Text('KidsLearn', style: textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Stories that grow with your child',
                style: textTheme.bodyLarge?.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
