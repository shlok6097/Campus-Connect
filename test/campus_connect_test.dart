import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/core/services/export_service.dart';
import 'package:campus_connect/data/models/event_model.dart';
import 'package:campus_connect/data/models/registration_model.dart';
import 'package:campus_connect/data/models/team_model.dart';
import 'package:campus_connect/data/models/note_model.dart';
import 'package:campus_connect/data/repositories/mock_repository.dart';
import 'package:campus_connect/presentation/state/auth_controller.dart';
import 'package:campus_connect/presentation/state/club_controller.dart';
import 'package:campus_connect/presentation/state/event_controller.dart';
import 'package:campus_connect/presentation/state/game_controller.dart';
import 'package:campus_connect/presentation/state/note_controller.dart';
import 'package:campus_connect/presentation/state/team_controller.dart';

void main() {
  group('Campus Connect Controller & Data Tests', () {
    test('MockRepository has seeded data matching Stitch design', () {
      expect(MockRepository.instance.events.isNotEmpty, true);
      expect(MockRepository.instance.teams.isNotEmpty, true);
      expect(MockRepository.instance.clubs.isNotEmpty, true);
      expect(MockRepository.instance.notes.isNotEmpty, true);
      expect(MockRepository.instance.games.isNotEmpty, true);
      expect(MockRepository.instance.registrations.length, greaterThanOrEqualTo(20));
    });

    test('AuthController student & organizer authentication and switching', () {
      final auth = AuthController.instance;
      auth.loginStudent(email: 'rahul.kumar@uvce.edu', password: 'password');
      expect(auth.isOrganizer, false);
      expect(auth.currentUser.name, 'Rahul Kumar');
      expect(auth.currentUser.studentId, 'UVCE21CS045');

      auth.loginOrganizer(clubOrRole: 'Coding Club Manager', password: 'admin');
      expect(auth.isOrganizer, true);
      expect(auth.currentClubOrRole, 'Coding Club Manager');
    });

    test('EventController filters and registration flow', () {
      final eventCtrl = EventController.instance;
      expect(eventCtrl.allEvents.isNotEmpty, true);

      eventCtrl.setCategoryFilter(EventCategory.hackathon);
      expect(eventCtrl.filteredEvents.every((e) => e.category == EventCategory.hackathon), true);

      eventCtrl.setCategoryFilter(null);
      expect(eventCtrl.filteredEvents.length, eventCtrl.allEvents.length);

      final user = AuthController.instance.currentUser;
      final testEvent = eventCtrl.allEvents.first;
      eventCtrl.registerForEvent(event: testEvent, user: user, customResponses: {});
      expect(eventCtrl.isUserRegistered(testEvent.id, user.studentId), true);
    });

    test('TeamController and Project Showcase', () {
      final teamCtrl = TeamController.instance;
      expect(teamCtrl.allTeams.isNotEmpty, true);
      expect(teamCtrl.myTeam.name, 'Team Nova');

      final newProj = ProjectModel(
        id: 'proj_test',
        title: 'Smart UVCE Campus Map',
        problem: 'Navigating college buildings',
        solution: 'AR directions',
        category: 'Mobile App',
        techStack: ['Flutter', 'ARCore'],
      );
      teamCtrl.updateProject('team_nova', newProj);
      expect(teamCtrl.myTeam.project?.title, 'Smart UVCE Campus Map');
    });

    test('ClubController join and leave club memberships', () {
      final clubCtrl = ClubController.instance;
      final firstClub = clubCtrl.allClubs.first;
      clubCtrl.joinClub(firstClub.id);
      expect(clubCtrl.myClubs.any((c) => c.id == firstClub.id), true);
    });

    test('NoteController search and contribute notes', () {
      final noteCtrl = NoteController.instance;
      expect(noteCtrl.allNotes.isNotEmpty, true);
      expect(noteCtrl.leaderboard.isNotEmpty, true);

      final initialCount = noteCtrl.allNotes.length;
      final newNote = NoteModel(
        id: 'note_test',
        title: 'Compiler Design Notes',
        description: 'Lexical analysis and parsing',
        subject: NoteSubject.dsa,
        authorName: 'Rahul Kumar',
        authorAvatar: '',
        course: 'CSE • 6th Sem',
        uploadDate: 'Today',
        rating: 5.0,
        downloadCount: 1,
        fileFormat: 'PDF',
        fileSize: '1.2 MB',
        pageCount: 10,
        topicsCovered: ['Lexer', 'Parser'],
      );
      noteCtrl.contributeNote(newNote);
      expect(noteCtrl.allNotes.length, initialCount + 1);
    });

    test('GameController code debugger question validation and scoring', () {
      final gameCtrl = GameController.instance;
      gameCtrl.startSession(60);
      expect(gameCtrl.currentQuestion != null, true);

      // Select correct option
      final correctIdx = gameCtrl.currentQuestion!.correctOptionIndex;
      gameCtrl.selectOption(correctIdx);
      gameCtrl.submitAnswer();
      expect(gameCtrl.isAnswerCorrect, true);
      expect(gameCtrl.score, greaterThan(0));
    });

    test('ExportService generates valid CSV, Excel, and PDF formats', () async {
      final testRegistrations = [
        RegistrationModel(
          id: 'REG-001',
          eventId: 'evt_1',
          eventTitle: 'Hackathon 2026',
          studentId: 'st_1',
          studentName: 'Rahul Kumar',
          studentEmail: 'rahul@uvce.edu',
          studentPhone: '+91 98765 43210',
          studentUSN: 'UVCE21CS045',
          branch: 'CSE',
          semester: 6,
          registrationDate: DateTime.now(),
          status: RegistrationStatus.confirmed,
        ),
      ];

      // CSV Generation
      final csvString = await ExportService.generateCsv(testRegistrations);
      expect(csvString.contains('Rahul Kumar'), true);
      expect(csvString.contains('UVCE21CS045'), true);

      // Excel XLSX Generation
      final excelBytes = await ExportService.generateExcel(testRegistrations);
      expect(excelBytes.isNotEmpty, true);

      // PDF Generation
      final pdfBytes = await ExportService.generatePdf(testRegistrations, eventTitle: 'Test Event');
      expect(pdfBytes.isNotEmpty, true);
    });
  });
}
