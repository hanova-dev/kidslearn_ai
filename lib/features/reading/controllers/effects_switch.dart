import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while ambient effects may be drawn; a too-slow phone turns them off until the app restarts (FR-MOTION-12).
class EffectsSwitch extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  /// Turns the effects off; the camera motion keeps going.
  void turnOff() {
    state = false;
  }
}

/// Lets the scene player read or change [EffectsSwitch].
final effectsAllowedProvider = NotifierProvider<EffectsSwitch, bool>(
  EffectsSwitch.new,
);
