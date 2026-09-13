import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/student_register_screen.dart';
import '../../presentation/screens/student/student_shell_screen.dart';
import '../../presentation/screens/organizer/organizer_shell_screen.dart';
import '../../presentation/screens/srm/srm_shell_screen.dart';
import '../../presentation/screens/events/events_list_screen.dart';
import '../../presentation/screens/teams/teams_hub_screen.dart';
import '../../presentation/screens/clubs/club_discovery_screen.dart';
import '../../presentation/screens/notes/notes_home_screen.dart';
import '../../presentation/screens/games/games_hub_screen.dart';
import '../../presentation/screens/organizer/create_event_screen.dart';
import '../../presentation/state/auth_controller.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String studentRegister = '/register-student';
  static const String studentShell = '/student';
  static const String clubShell = '/club';
  static const String organizerShell = '/organizer';
  static const String srmShell = '/srm';
  static const String events = '/events';
  static const String teams = '/teams';
  static const String clubs = '/clubs';
  static const String notes = '/notes';
  static const String games = '/games';
  static const String createEvent = '/organizer/create-event';

  /// Helper to get the correct dashboard route for an authenticated user
  static String getDashboardRoute(UserModel user) {
    if (user.isSrmAdmin) {
      return srmShell;
    }
    if (user.isClubLeader) {
      return clubShell;
    }
    return studentShell;
  }

  /// Builds a protected route with account type guard
  static Route<dynamic> _protectedRoute({
    required Widget targetScreen,
    required AccountType requiredAccountType,
    required String routeName,
  }) {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (context) {
        final auth = AuthController.instance;

        // 1. Unauthenticated check
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // 2. Role/Account type authorization check
        final isClubAuthorized = requiredAccountType == AccountType.club && auth.currentUser.isClubLeader;
        final isSrmAuthorized = requiredAccountType == AccountType.srm && auth.currentUser.isSrmAdmin;
        final isStudentAuthorized = requiredAccountType == AccountType.student;

        final isAuthorized = (auth.accountType == requiredAccountType) ||
            isClubAuthorized ||
            isSrmAuthorized ||
            isStudentAuthorized;

        if (!isAuthorized) {
          return Scaffold(
            appBar: AppBar(title: const Text('Unauthorized Access')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gpp_maybe, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Access Restricted',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account (${auth.currentRole.displayName}) is not authorized to access this dashboard.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final validRoute = getDashboardRoute(auth.currentUser);
                        Navigator.of(context).pushReplacementNamed(validRoute);
                      },
                      child: const Text('Return to My Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return targetScreen;
      },
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case studentRegister:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const StudentRegisterScreen(),
        );

      case studentShell:
        return _protectedRoute(
          targetScreen: const StudentShellScreen(),
          requiredAccountType: AccountType.student,
          routeName: studentShell,
        );

      case clubShell:
      case organizerShell:
        return _protectedRoute(
          targetScreen: const OrganizerShellScreen(),
          requiredAccountType: AccountType.club,
          routeName: clubShell,
        );

      case srmShell:
        return _protectedRoute(
          targetScreen: const SrmShellScreen(),
          requiredAccountType: AccountType.srm,
          routeName: srmShell,
        );

      case events:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EventsListScreen(),
        );

      case teams:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TeamsHubScreen(),
        );

      case clubs:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ClubDiscoveryScreen(),
        );

      case notes:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotesHomeScreen(),
        );

      case games:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GamesHubScreen(),
        );

      case createEvent:
        return _protectedRoute(
          targetScreen: const CreateEventScreen(),
          requiredAccountType: AccountType.club,
          routeName: createEvent,
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('404 Not Found')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Page not found', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final auth = AuthController.instance;
                      if (auth.isAuthenticated) {
                        Navigator.of(context).pushReplacementNamed(getDashboardRoute(auth.currentUser));
                      } else {
                        Navigator.of(context).pushReplacementNamed(login);
                      }
                    },
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
