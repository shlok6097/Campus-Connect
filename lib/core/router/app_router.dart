import 'package:flutter/material.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/student_register_screen.dart';
import '../../presentation/screens/student/student_shell_screen.dart';
import '../../presentation/screens/organizer/organizer_shell_screen.dart';
import '../../presentation/screens/events/events_list_screen.dart';
import '../../presentation/screens/teams/teams_hub_screen.dart';
import '../../presentation/screens/clubs/club_discovery_screen.dart';
import '../../presentation/screens/notes/notes_home_screen.dart';
import '../../presentation/screens/games/games_hub_screen.dart';
import '../../presentation/screens/organizer/create_event_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String studentRegister = '/register-student';
  static const String studentShell = '/student';
  static const String organizerShell = '/organizer';
  static const String events = '/events';
  static const String teams = '/teams';
  static const String clubs = '/clubs';
  static const String notes = '/notes';
  static const String games = '/games';
  static const String createEvent = '/organizer/create-event';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case studentRegister:
        return MaterialPageRoute(builder: (_) => const StudentRegisterScreen());
      case studentShell:
        return MaterialPageRoute(builder: (_) => const StudentShellScreen());
      case organizerShell:
        return MaterialPageRoute(builder: (_) => const OrganizerShellScreen());
      case events:
        return MaterialPageRoute(builder: (_) => const EventsListScreen());
      case teams:
        return MaterialPageRoute(builder: (_) => const TeamsHubScreen());
      case clubs:
        return MaterialPageRoute(builder: (_) => const ClubDiscoveryScreen());
      case notes:
        return MaterialPageRoute(builder: (_) => const NotesHomeScreen());
      case games:
        return MaterialPageRoute(builder: (_) => const GamesHubScreen());
      case createEvent:
        return MaterialPageRoute(builder: (_) => const CreateEventScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
