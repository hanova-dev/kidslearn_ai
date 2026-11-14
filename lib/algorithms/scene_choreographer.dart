import '../data/models/motion_directive.dart';
import '../policy/motion_profile.dart';
import 'camera_frame.dart';
import 'motion_timeline.dart';

/// Turns a page's motion directive into a camera timeline; the same input always gives the same timeline (FR-MOTION-04).
class SceneChoreographer {
  const SceneChoreographer();

  /// The camera timeline for one page.
  ///
  /// [rightToLeft] mirrors pans (FR-MOTION-10); [reduceMotion] gives a still picture (FR-MOTION-06).
  MotionTimeline timelineFor(
    MotionDirective directive,
    MotionProfile profile, {
    required bool rightToLeft,
    required bool reduceMotion,
  }) {
    if (reduceMotion) {
      return MotionTimeline.still;
    }

    // ── How far the picture may shift without showing its edge ──
    final zoom = profile.maxZoom;
    final reach = (zoom - 1) / 2;
    final mirror = rightToLeft ? -1.0 : 1.0;
    final focused = _focusFrame(directive.focus, zoom, reach);

    // ── One move per camera word ──
    switch (directive.camera) {
      case 'slow_zoom_in':
        return _move(profile, CameraFrame.plain, focused);
      case 'slow_zoom_out':
        return _move(profile, focused, CameraFrame.plain);
      case 'pan_left':
        return _pan(profile, -reach * mirror, reach * mirror, 0, 0);
      case 'pan_right':
        return _pan(profile, reach * mirror, -reach * mirror, 0, 0);
      case 'pan_up':
        return _pan(profile, 0, 0, -reach, reach);
      case 'pan_down':
        return _pan(profile, 0, 0, reach, -reach);
      default:
        return MotionTimeline.still;
    }
  }

  // ── The cue word was spoken: ease from where the camera is to the focus point (FR-MOTION-07) ──
  /// A short timeline from [from] to the zoomed-in focus frame.
  MotionTimeline cueTimelineFor(
    CameraFrame from,
    MotionDirective directive,
    MotionProfile profile, {
    required bool reduceMotion,
  }) {
    if (reduceMotion) {
      return MotionTimeline.still;
    }
    final zoom = profile.maxZoom;
    final focused = _focusFrame(directive.focus, zoom, (zoom - 1) / 2);
    return MotionTimeline([
      CameraKeyframe(atMs: 0, frame: from),
      CameraKeyframe(atMs: profile.cueMs, frame: focused),
    ]);
  }

  // ── Zoomed in on the focus point (the picture is not mirrored, so focus is not either) ──
  CameraFrame _focusFrame(String focus, double zoom, double reach) {
    switch (focus) {
      case 'left':
        return CameraFrame(scale: zoom, dx: reach, dy: 0);
      case 'right':
        return CameraFrame(scale: zoom, dx: -reach, dy: 0);
      case 'top':
        return CameraFrame(scale: zoom, dx: 0, dy: reach);
      case 'bottom':
        return CameraFrame(scale: zoom, dx: 0, dy: -reach);
      default:
        return CameraFrame(scale: zoom, dx: 0, dy: 0);
    }
  }

  // ── A pan: zoomed in, sliding from one side to the other ──
  MotionTimeline _pan(
    MotionProfile profile,
    double fromDx,
    double toDx,
    double fromDy,
    double toDy,
  ) {
    final zoom = profile.maxZoom;
    return _move(
      profile,
      CameraFrame(scale: zoom, dx: fromDx, dy: fromDy),
      CameraFrame(scale: zoom, dx: toDx, dy: toDy),
    );
  }

  MotionTimeline _move(
    MotionProfile profile,
    CameraFrame from,
    CameraFrame to,
  ) {
    return MotionTimeline([
      CameraKeyframe(atMs: 0, frame: from),
      CameraKeyframe(atMs: profile.cameraMs, frame: to),
    ]);
  }
}
