import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/controllers/parent_unlock.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/parental_gate_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/children/screens/add_child_screen.dart';
import '../features/children/screens/parent_home_screen.dart';
import '../features/children/screens/who_is_reading_screen.dart';
import '../features/reading/screens/path_map_screen.dart';
import '../features/stories/screens/create_story_screen.dart';
import '../features/stories/screens/story_generating_screen.dart';
import '../features/stories/screens/story_preview_screen.dart';
import 'providers.dart';

/// Paths of every screen, so no screen types a path by hand.
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String parentalGate = '/gate';
  static const String parentHome = '/parent';
  static const String addChild = '/add-child';
  static const String whoIsReading = '/who';
  static const String pathMap = '/path';
  static const String createStory = '/create-story';
  static const String storyGenerating = '/story-generating';
  static const String storyPreview = '/story-preview';

  /// The preview path for one story, e.g. `/story-preview?id=story-1`.
  static String storyPreviewOf(String storyId) {
    return '$storyPreview?id=$storyId';
  }

  /// Screens only an unlocked parent may open (SRS D7).
  static const List<String> parentArea = [
    parentHome,
    addChild,
    createStory,
    storyGenerating,
    storyPreview,
  ];
}

/// Builds the router with two guards: sign-in (FR-AUTH-03) and parental gate (FR-AUTH-04).
GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSignedIn = ref.read(authRepositoryProvider).currentUserId != null;
      final isUnlocked = ref.read(parentUnlockProvider);

      if (location == AppRoutes.splash) {
        return null;
      }

      // ── Sign-in guard ──
      if (!isSignedIn) {
        if (location == AppRoutes.login) {
          return null;
        }
        return AppRoutes.login;
      }
      if (location == AppRoutes.login) {
        if (isUnlocked) {
          return AppRoutes.parentHome;
        }
        return AppRoutes.whoIsReading;
      }

      // ── Parental gate guard ──
      if (AppRoutes.parentArea.contains(location) && !isUnlocked) {
        return AppRoutes.parentalGate;
      }
      if (location == AppRoutes.parentalGate && isUnlocked) {
        return AppRoutes.parentHome;
      }
      return null;
    },

    // ── Screens ──
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentalGate,
        builder: (context, state) => const ParentalGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentHome,
        builder: (context, state) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.addChild,
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: AppRoutes.whoIsReading,
        builder: (context, state) => const WhoIsReadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.pathMap,
        builder: (context, state) => const PathMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.createStory,
        builder: (context, state) => const CreateStoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.storyGenerating,
        builder: (context, state) => const StoryGeneratingScreen(),
      ),
      GoRoute(
        path: AppRoutes.storyPreview,
        builder: (context, state) =>
            StoryPreviewScreen(storyId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],
  );
}
