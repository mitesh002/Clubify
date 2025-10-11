import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/student/presentation/screens/student_main_screen.dart';
import '../../features/student/presentation/screens/dashboard_screen.dart';
import '../../features/student/presentation/screens/event_details_screen.dart';
import '../../features/student/presentation/screens/my_activities_screen.dart';
import '../../features/student/presentation/screens/leaderboard_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';
import '../../features/club_leader/presentation/screens/club_leader_main_screen.dart';
import '../../features/club_leader/presentation/screens/club_profile_screen.dart';
import '../../features/club_leader/presentation/screens/create_event_screen.dart';
import '../../features/club_leader/presentation/screens/event_history_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/announcements/presentation/screens/announcements_screen.dart';
import '../../features/directory/presentation/screens/club_directory_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';

// Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnAuthPage = state.fullPath?.startsWith('/auth') ?? false;
      final isOnSplash = state.fullPath == '/splash';
      final isOnOnboarding = state.fullPath == '/onboarding';

      // If not logged in and not on auth/splash/onboarding pages, redirect to auth
      if (!isLoggedIn && !isOnAuthPage && !isOnSplash && !isOnOnboarding) {
        return '/auth';
      }

      // If logged in and on auth pages, redirect to appropriate home
      if (isLoggedIn && isOnAuthPage) {
        // Wait for user profile to load to determine role
        if (currentUser.isLoading) return null;
        final user = currentUser.value;
        if (user == null) return null;
        return user.role == 'club_leader' ? '/club-leader' : '/student';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),

      // Student Routes
      GoRoute(
        path: '/student',
        name: 'student',
        builder: (context, state) => const StudentMainScreen(),
        routes: [
          GoRoute(
            path: 'announcements',
            name: 'announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: 'directory',
            name: 'directory',
            builder: (context, state) => const ClubDirectoryScreen(),
          ),
          GoRoute(
            path: 'resources/:clubId',
            name: 'resources',
            builder: (context, state) {
              final clubId = state.pathParameters['clubId']!;
              return ResourcesScreen(clubId: clubId);
            },
          ),
          GoRoute(
            path: 'dashboard',
            name: 'student-dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'event/:eventId',
            name: 'event-details',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              final queryParams = state.uri.queryParameters;
              return EventDetailsScreen(
                eventId: eventId,
                clubId: queryParams['clubId'] ?? '',
                title: queryParams['title'] ?? 'Event',
                description: queryParams['description'] ?? '',
                dateTime: DateTime.tryParse(queryParams['dateTime'] ?? '') ?? DateTime.now(),
                venue: queryParams['venue'] ?? '',
                maxParticipants: int.tryParse(queryParams['maxParticipants'] ?? '0') ?? 0,
                imageUrl: queryParams['imageUrl'],
              );
            },
          ),
          GoRoute(
            path: 'activities',
            name: 'my-activities',
            builder: (context, state) => const MyActivitiesScreen(),
          ),
          GoRoute(
            path: 'leaderboard',
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'student-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Club Leader Routes
      GoRoute(
        path: '/club-leader',
        name: 'club-leader',
        builder: (context, state) => const ClubLeaderMainScreen(),
        routes: [
          GoRoute(
            path: 'club-profile',
            name: 'club-profile',
            builder: (context, state) => const ClubProfileScreen(),
          ),
          GoRoute(
            path: 'create-event',
            name: 'create-event',
            builder: (context, state) => const CreateEventScreen(),
          ),
          // Registrations flow removed: students must be members; leaders manage membership
          GoRoute(
            path: 'event-history',
            name: 'event-history',
            builder: (context, state) => const EventHistoryScreen(),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Custom Page Transitions
class SlideTransitionPage extends CustomTransitionPage<void> {
  const SlideTransitionPage({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: _slideTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _slideTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: child,
    );
  }
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: _fadeTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
        );

  static Widget _fadeTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
