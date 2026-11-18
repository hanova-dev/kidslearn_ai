import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/scene.dart';
import '../../../policy/age_experience_policy.dart';
import 'motion_scene_player.dart';
import 'scene_picture.dart';

/// One page of the story viewer: the moving picture and the still sentence (design p13).
class ViewerPage extends StatelessWidget {
  const ViewerPage({super.key, required this.scene, required this.cueHeard});

  final Scene scene;

  /// True once the voice has said this page's cue word (FR-MOTION-07).
  final bool cueHeard;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        // ── Scene picture (or scenery if it is missing), moved by the camera ──
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border, width: 2),
          ),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: MotionScenePlayer(
              key: ValueKey(scene.id),
              directive: scene.motion,
              profile: const ListenerPolicy().motion,
              cueHeard: cueHeard,
              child: ScenePicture(path: scene.imagePath),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Sentence in Andika ──
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                scene.text,
                style: TextStyle(
                  fontFamily: AppFonts.andika,
                  fontSize: const ListenerPolicy().storyTextSize,
                  height: 1.4,
                  color: colors.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
