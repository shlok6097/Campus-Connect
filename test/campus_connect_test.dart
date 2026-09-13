import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/core/services/export_service.dart';
import 'package:campus_connect/data/models/club_model.dart';
import 'package:campus_connect/data/models/event_model.dart';
import 'package:campus_connect/data/models/registration_model.dart';
import 'package:campus_connect/data/models/team_model.dart';
import 'package:campus_connect/data/models/note_model.dart';
import 'package:campus_connect/data/models/publication_model.dart';
import 'package:campus_connect/data/repositories/mock_repository.dart';
import 'package:campus_connect/presentation/shared/cards/payment_qr_card.dart';
import 'package:campus_connect/presentation/state/auth_controller.dart';
import 'package:campus_connect/presentation/state/club_controller.dart';
import 'package:campus_connect/presentation/state/event_controller.dart';
import 'package:campus_connect/presentation/state/game_controller.dart';
import 'package:campus_connect/presentation/state/note_controller.dart';
import 'package:campus_connect/presentation/state/publish_controller.dart';
import 'package:campus_connect/presentation/state/team_controller.dart';

void main() {
  group('Campus Connect Controller & Data Tests', () {
    setUp(() {
      MockRepository.instance.seedMockDataForTesting();
    });

    test('MockRepository has seeded data matching Stitch design', () {
      expect(MockRepository.instance.events.isNotEmpty, true);
      expect(MockRepository.instance.teams.isNotEmpty, true);
      expect(MockRepository.instance.clubs.isNotEmpty, true);
      expect(MockRepository.instance.notes.isNotEmpty, true);
      expect(MockRepository.instance.games.isNotEmpty, true);
      expect(MockRepository.instance.registrations.length, greaterThanOrEqualTo(20));
    });

    test('AuthController student & club leader authentication and role detection', () async {
      final auth = AuthController.instance;
      final studentSuccess = await auth.login(identifier: 'rahul.kumar@uvce.edu', password: 'password123');
      expect(studentSuccess, true);
      expect(auth.isStudent, true);
      expect(auth.isStudentMember, true);
      expect(auth.currentUser.name, 'Rahul Kumar');
      expect(auth.currentUser.studentId, 'UVCE21CS045');

      final clubSuccess = await auth.login(identifier: 'codingclub@uvce.edu', password: 'club123');
      expect(clubSuccess, true);
      expect(auth.isClub, true);
      expect(auth.isClubLeader, true);
      expect(auth.currentUser.clubName, 'Coding Club UVCE');
    });

    test('EventController filters and registration flow', () {
      final eventCtrl = EventController.instance;
      if (eventCtrl.allEvents.isEmpty && MockRepository.instance.events.isNotEmpty) {
        for (final e in MockRepository.instance.events) {
          eventCtrl.createEvent(e);
        }
      }
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

    test('ClubController join and leave club memberships', () async {
      final clubCtrl = ClubController.instance;
      final firstClub = clubCtrl.allClubs.first;
      final initialCount = firstClub.memberCount;

      await clubCtrl.joinClub(firstClub.id);
      expect(clubCtrl.myClubs.any((c) => c.id == firstClub.id), true);
      expect(clubCtrl.allClubs.firstWhere((c) => c.id == firstClub.id).memberCount, initialCount + 1);

      await clubCtrl.leaveClub(firstClub.id);
      expect(clubCtrl.myClubs.any((c) => c.id == firstClub.id), false);
      expect(clubCtrl.allClubs.firstWhere((c) => c.id == firstClub.id).memberCount, initialCount);
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

    test('PaymentQRCard dynamic UPI URI generation format', () {
      final card = PaymentQRCard(
        upiId: 'codingclub@okaxis',
        amount: 250.0,
        eventName: 'CodeSprint 2026',
      );
      expect(card.upiUri, 'upi://pay?pa=codingclub@okaxis&pn=CodeSprint%202026&am=250.00&cu=INR');
    });

    test('EventController free and paid event registration flows', () async {
      final eventCtrl = EventController.instance;
      final user = AuthController.instance.currentUser;

      // Free Event
      final freeEvent = EventModel(
        id: 'evt_free_test',
        title: 'Free Workshop',
        description: 'Free event',
        category: EventCategory.workshop,
        bannerUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        timeString: '10:00 AM - 1:00 PM',
        venue: 'Lab 1',
        organizerName: 'Tech Club',
        maxParticipants: 100,
        entryFee: 0.0,
      );

      final freeSuccess = await eventCtrl.registerForEvent(
        event: freeEvent,
        user: user,
        customResponses: {'T-Shirt': 'M'},
        paymentStatus: 'free',
        amount: 0.0,
      );
      expect(freeSuccess, true);

      // Paid Event
      final paidEvent = EventModel(
        id: 'evt_paid_test',
        title: 'Paid Hackathon',
        description: 'Paid event',
        category: EventCategory.hackathon,
        bannerUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        timeString: '9:00 AM - 6:00 PM',
        venue: 'Auditorium',
        organizerName: 'Tech Club',
        maxParticipants: 100,
        entryFee: 199.0,
        paymentUpiId: 'techclub@upi',
      );

      final paidSuccess = await eventCtrl.registerForEvent(
        event: paidEvent,
        user: user,
        customResponses: {'Diet': 'Veg'},
        paymentStatus: 'pending',
        paymentReference: 'UTR9876543210',
        amount: 199.0,
      );
      expect(paidSuccess, true);

      final paidReg = eventCtrl.allRegistrations.firstWhere((r) => r.eventId == 'evt_paid_test');
      expect(paidReg.paymentStatus, 'pending');
      expect(paidReg.paymentReference, 'UTR9876543210');
      expect(paidReg.amount, 199.0);
    });

    test('Club Leader event isolation and published filter', () async {
      final eventCtrl = EventController.instance;

      final clubAEvent = EventModel(
        id: 'evt_club_a',
        title: 'Club A Event',
        description: 'Desc',
        category: EventCategory.workshop,
        bannerUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        timeString: '10 AM',
        venue: 'Hall A',
        organizerName: 'Coding Club',
        maxParticipants: 50,
        isPublished: true,
      );

      final clubADraft = EventModel(
        id: 'evt_club_a_draft',
        title: 'Club A Draft',
        description: 'Draft',
        category: EventCategory.workshop,
        bannerUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        timeString: '10 AM',
        venue: 'Hall A',
        organizerName: 'Coding Club',
        maxParticipants: 50,
        isPublished: false,
      );

      final clubBEvent = EventModel(
        id: 'evt_club_b',
        title: 'Club B Event',
        description: 'Desc',
        category: EventCategory.cultural,
        bannerUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        timeString: '2 PM',
        venue: 'Hall B',
        organizerName: 'Dance Club',
        maxParticipants: 50,
        isPublished: true,
      );

      await eventCtrl.createEvent(clubAEvent);
      await eventCtrl.createEvent(clubADraft);
      await eventCtrl.createEvent(clubBEvent);

      final codingClubPublished = eventCtrl.getClubPublishedEvents(clubName: 'Coding Club');
      expect(codingClubPublished.any((e) => e.id == 'evt_club_a'), true);
      expect(codingClubPublished.any((e) => e.id == 'evt_club_a_draft'), false);
      expect(codingClubPublished.any((e) => e.id == 'evt_club_b'), false);
    });

    test('Club Leader updateEvent and payment verification', () async {
      final eventCtrl = EventController.instance;
      final originalEvent = eventCtrl.allEvents.first;

      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Event Title 2026',
        entryFee: 250.0,
      );

      final updateSuccess = await eventCtrl.updateEvent(updatedEvent);
      expect(updateSuccess, true);

      final fetched = eventCtrl.allEvents.firstWhere((e) => e.id == originalEvent.id);
      expect(fetched.title, 'Updated Event Title 2026');
      expect(fetched.entryFee, 250.0);

      // Payment status update
      if (eventCtrl.allRegistrations.isNotEmpty) {
        final reg = eventCtrl.allRegistrations.first;
        await eventCtrl.updatePaymentStatus(reg.id, 'verified');
        final updatedReg = eventCtrl.allRegistrations.firstWhere((r) => r.id == reg.id);
        expect(updatedReg.paymentStatus, 'verified');
      }
    });

    test('EventUpdateModel and EventNotificationModel serialization', () {
      final update = EventUpdateModel(
        id: 'upd_1',
        eventId: 'evt_1',
        title: 'Venue changed',
        message: 'Main Auditorium',
        createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
      );

      final updateJson = update.toJson();
      expect(updateJson['id'], 'upd_1');
      expect(updateJson['title'], 'Venue changed');

      final deserializedUpdate = EventUpdateModel.fromJson(updateJson);
      expect(deserializedUpdate.title, 'Venue changed');
      expect(deserializedUpdate.message, 'Main Auditorium');

      final notification = EventNotificationModel(
        id: 'notif_1',
        eventId: 'evt_1',
        title: 'Reminder',
        message: 'Bring your ID',
        recipientGroup: 'confirmed',
        createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
      );

      final notifJson = notification.toJson();
      expect(notifJson['recipient_group'], 'confirmed');
      final deserializedNotif = EventNotificationModel.fromJson(notifJson);
      expect(deserializedNotif.recipientGroup, 'confirmed');
    });

    test('PublicationModel serialization and PublishController state', () async {
      final pub = PublicationModel(
        id: 'pub_test_1',
        clubName: 'Test club',
        type: PublicationType.poll,
        title: 'Tech Stack Poll',
        content: 'Which frontend framework do you prefer?',
        metadata: {
          'total_votes': 10,
          'options': [
            {'label': 'Flutter', 'votes': 6, 'percent': 60},
            {'label': 'React Native', 'votes': 4, 'percent': 40},
          ]
        },
        authorName: 'Leader',
        createdAt: DateTime.parse('2026-08-26T12:00:00.000Z'),
      );

      final pubJson = pub.toJson();
      expect(pubJson['id'], 'pub_test_1');
      expect(pubJson['type'], 'poll');

      final deserialized = PublicationModel.fromJson(pubJson);
      expect(deserialized.title, 'Tech Stack Poll');
      expect(deserialized.type, PublicationType.poll);

      // Test Controller
      final ctrl = PublishController.instance;
      await ctrl.publishContent(pub);
      expect(ctrl.allPublications.any((p) => p.id == 'pub_test_1'), true);

      // Test Filter
      ctrl.setFilter('POLL');
      expect(ctrl.filteredPublications.every((p) => p.type == PublicationType.poll), true);

      // Test Poll Voting
      ctrl.voteOnPoll('pub_test_1', 0);
      final updatedPub = ctrl.allPublications.firstWhere((p) => p.id == 'pub_test_1');
      final opts = updatedPub.metadata['options'] as List;
      expect(opts[0]['votes'], 7);
      expect(updatedPub.metadata['total_votes'], 11);

      ctrl.setFilter('ALL');
    });

    test('ClubMemberItem privileges and ClubController member management', () async {
      final clubCtrl = ClubController.instance;
      final testClubId = clubCtrl.allClubs.isNotEmpty ? clubCtrl.allClubs.first.id : 'club_test';

      final member = ClubMemberItem(
        id: 'mem_test_101',
        name: 'Aarav Patel',
        email: 'aarav@uvce.edu',
        usn: '1UV22CS101',
        role: 'Event Coordinator',
        branch: 'CSE',
        semester: 4,
        avatarUrl: '',
        joinedDate: 'Today',
        isManager: false,
        privileges: ['manage_events', 'view_responses', 'checkin_attendees'],
      );

      // Verify privilege getters
      expect(member.canManageEvents, true);
      expect(member.canViewResponses, true);
      expect(member.canCheckIn, true);
      expect(member.canPublish, false);
      expect(member.canManageMembers, false);

      // Add member
      await clubCtrl.addMemberToClub(testClubId, member);
      final club = clubCtrl.allClubs.firstWhere((c) => c.id == testClubId);
      expect(club.members.any((m) => m.id == 'mem_test_101'), true);

      // Update member privileges
      await clubCtrl.updateMemberRoleAndPrivileges(
        testClubId,
        'mem_test_101',
        'Technical Lead',
        false,
        ['manage_events', 'publish_content'],
      );
      final updatedClub = clubCtrl.allClubs.firstWhere((c) => c.id == testClubId);
      final updatedMem = updatedClub.members.firstWhere((m) => m.id == 'mem_test_101');
      expect(updatedMem.role, 'Technical Lead');
      expect(updatedMem.canPublish, true);

      // Remove member
      await clubCtrl.removeMemberFromClub(testClubId, 'mem_test_101');
      final afterRemoveClub = clubCtrl.allClubs.firstWhere((c) => c.id == testClubId);
      expect(afterRemoveClub.members.any((m) => m.id == 'mem_test_101'), false);
    });
  });
}
