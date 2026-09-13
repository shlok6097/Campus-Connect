import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/core/router/app_router.dart';
import 'package:campus_connect/core/services/session_service.dart';
import 'package:campus_connect/data/models/auth_session_model.dart';
import 'package:campus_connect/data/models/user_model.dart';
import 'package:campus_connect/data/repositories/srm_repository.dart';
import 'package:campus_connect/presentation/state/auth_controller.dart';
import 'package:campus_connect/presentation/state/srm_controller.dart';

void main() {
  group('Campus Connect Unified Authentication & SRM Backend Tests', () {
    late AuthController auth;

    setUp(() {
      auth = AuthController.instance;
    });

    test('1. Unified Login: Student Member authentication and role resolution', () async {
      final success = await auth.login(
        identifier: 'rahul.kumar@uvce.edu',
        password: 'password123',
      );

      expect(success, true);
      expect(auth.isAuthenticated, true);
      expect(auth.accountType, AccountType.student);
      expect(auth.currentRole, UserRole.studentMember);
      expect(auth.isStudent, true);
      expect(auth.isStudentMember, true);
      expect(auth.isClub, false);
      expect(auth.isSrm, false);
      expect(AppRoutes.getDashboardRoute(auth.currentUser), AppRoutes.studentShell);
    });

    test('2. Unified Login: Student Leader authentication and role resolution', () async {
      final success = await auth.login(
        identifier: 'ananya.sharma@uvce.edu',
        password: 'leader123',
      );

      expect(success, true);
      expect(auth.accountType, AccountType.student);
      expect(auth.currentRole, UserRole.studentLeader);
      expect(auth.isStudent, true);
      expect(auth.isStudentLeader, true);
      expect(AppRoutes.getDashboardRoute(auth.currentUser), AppRoutes.studentShell);
    });

    test('3. Unified Login: Club Leader authentication and role resolution', () async {
      final success = await auth.login(
        identifier: 'codingclub@uvce.edu',
        password: 'club123',
      );

      expect(success, true);
      expect(auth.accountType, AccountType.club);
      expect(auth.currentRole, UserRole.clubLeader);
      expect(auth.isClub, true);
      expect(auth.isClubLeader, true);
      expect(auth.currentUser.clubName, 'Coding Club UVCE');
      expect(AppRoutes.getDashboardRoute(auth.currentUser), AppRoutes.clubShell);
    });

    test('4. Unified Login: Club Member authentication and role resolution', () async {
      final success = await auth.login(
        identifier: 'robotics.member@uvce.edu',
        password: 'member123',
      );

      expect(success, true);
      expect(auth.accountType, AccountType.club);
      expect(auth.currentRole, UserRole.clubMember);
      expect(auth.isClub, true);
      expect(auth.isClubMember, true);
      expect(auth.currentUser.clubName, 'Robotics & Automation Club');
      expect(AppRoutes.getDashboardRoute(auth.currentUser), AppRoutes.clubShell);
    });

    test('5. Unified Login: SRM Administrator authentication and role resolution', () async {
      final success = await auth.login(
        identifier: 'admin.srm@uvce.edu',
        password: 'srm123',
      );

      expect(success, true);
      expect(auth.accountType, AccountType.srm);
      expect(auth.currentRole, UserRole.srmAdministrator);
      expect(auth.isSrm, true);
      expect(auth.isSrmAdministrator, true);
      expect(auth.currentUser.srmId, 'SRM_CAMPUS_MAIN');
      expect(AppRoutes.getDashboardRoute(auth.currentUser), AppRoutes.srmShell);
    });

    test('6. Unified Login: Identifier versatility (Email vs USN vs Username)', () async {
      // Login with USN
      final usnSuccess = await auth.login(
        identifier: 'UVCE21CS045',
        password: 'password123',
      );
      expect(usnSuccess, true);
      expect(auth.currentUser.name, 'Rahul Kumar');

      // Login with SRM Admin ID
      final srmIdSuccess = await auth.login(
        identifier: 'SRM_ADMIN_01',
        password: 'srm123',
      );
      expect(srmIdSuccess, true);
      expect(auth.currentUser.role, UserRole.srmAdministrator);
    });

    test('7. Error Handling: Incorrect password and unknown account', () async {
      // Wrong password
      final wrongPw = await auth.login(
        identifier: 'rahul.kumar@uvce.edu',
        password: 'wrong_password',
      );
      expect(wrongPw, false);
      expect(auth.errorMessage, contains('Incorrect password'));

      // Unknown user
      final unknownUser = await auth.login(
        identifier: 'nonexistent@uvce.edu',
        password: 'password123',
      );
      expect(unknownUser, false);
      expect(auth.errorMessage, contains('No account found'));
    });

    test('8. Student Account Creation: Assigns Student Member role, endingYear, and branch', () async {
      final regSuccess = await auth.registerStudent(
        name: 'Kavya Rao',
        studentId: 'UVCE23IS088',
        email: 'kavya.rao@uvce.edu',
        phone: '+91 98765 99999',
        branch: 'AIML (AIDS)',
        endingYear: 2027,
        password: 'kavyaPassword123',
      );

      expect(regSuccess, true);
      expect(auth.currentUser.name, 'Kavya Rao');
      expect(auth.currentUser.branch, 'AIML (AIDS)');
      expect(auth.currentUser.endingYear, 2027);
      expect(auth.currentUser.accountType, AccountType.student);
      expect(auth.currentUser.role, UserRole.studentMember); // Strictly Student Member
      expect(auth.isStudentMember, true);
      expect(auth.isClub, false);
      expect(auth.isSrm, false);

      // Verify custom specified branch registration
      final customBranchSuccess = await auth.registerStudent(
        name: 'Aarav Patel',
        studentId: 'UVCE24BT012',
        email: 'aarav.patel@uvce.edu',
        phone: '+91 98765 88888',
        branch: 'Bio-Technology',
        endingYear: 2028,
        password: 'aaravPassword123',
      );
      expect(customBranchSuccess, true);
      expect(auth.currentUser.name, 'Aarav Patel');
      expect(auth.currentUser.branch, 'Bio-Technology');
      expect(auth.currentUser.endingYear, 2028);

      // Verify student registration without Student ID / USN (optional)
      final noIdSuccess = await auth.registerStudent(
        name: 'Sneha Reddy',
        email: 'sneha.reddy@uvce.edu',
        phone: '+91 98765 77777',
        branch: 'ECE',
        endingYear: 2026,
        password: 'snehaPassword123',
      );
      expect(noIdSuccess, true);
      expect(auth.currentUser.name, 'Sneha Reddy');
      expect(auth.currentUser.studentId, '');
      expect(auth.currentUser.branch, 'ECE');
      expect(auth.currentUser.endingYear, 2026);

      // Verify duplicate email is prevented
      final dupSuccess = await auth.registerStudent(
        name: 'Kavya Duplicate',
        studentId: 'UVCE23IS089',
        email: 'kavya.rao@uvce.edu',
        phone: '+91 98765 99998',
        branch: 'ISE',
        endingYear: 2027,
        password: 'password123',
      );
      expect(dupSuccess, false);
      expect(auth.errorMessage, contains('already exists'));
    });

    test('9. Session Storage, Persistence, and Restoration', () async {
      // 1. Authenticate SRM
      await auth.login(identifier: 'admin.srm@uvce.edu', password: 'srm123');
      final session = auth.currentSession;
      expect(session != null, true);
      expect(session!.isValid, true);
      expect(session.isExpired, false);

      // 2. Test JSON serialization
      final json = session.toJson();
      final deserialized = AuthSession.fromJson(json);
      expect(deserialized.token, session.token);
      expect(deserialized.user.role, UserRole.srmAdministrator);

      // 3. Restore session
      final restored = await auth.restoreSession();
      expect(restored, true);
      expect(auth.accountType, AccountType.srm);

      // 4. Logout
      await auth.logout();
      expect(auth.currentSession, isNull);
      expect(SessionService.instance.currentSession, isNull);
    });

    test('10. Role and Account Type enum deserialization robustness', () {
      expect(AccountType.fromString('student'), AccountType.student);
      expect(AccountType.fromString('club'), AccountType.club);
      expect(AccountType.fromString('srm'), AccountType.srm);
      expect(AccountType.fromString('invalid'), AccountType.student);

      expect(UserRole.fromString('student_member'), UserRole.studentMember);
      expect(UserRole.fromString('student_leader'), UserRole.studentLeader);
      expect(UserRole.fromString('club_member'), UserRole.clubMember);
      expect(UserRole.fromString('club_leader'), UserRole.clubLeader);
      expect(UserRole.fromString('srm_administrator'), UserRole.srmAdministrator);
      expect(UserRole.fromString('srm_admin'), UserRole.srmAdministrator);

      // Legacy role aliases
      expect(UserRole.fromString('student'), UserRole.studentMember);
      expect(UserRole.fromString('organizer'), UserRole.clubLeader);
    });

    test('11. SRM Dashboard & Club Management Backend Repository & Controller', () async {
      final srmCtrl = SrmController.instance;
      await srmCtrl.loadDashboard();

      expect(srmCtrl.stats.totalClubs, greaterThanOrEqualTo(0));
      expect(srmCtrl.stats.activeClubs, greaterThanOrEqualTo(0));
      expect(srmCtrl.stats.totalStudents, greaterThanOrEqualTo(0));

      final availableStudents = await SrmRepository.instance.getEligibleStudents();
      expect(availableStudents.isNotEmpty, true);

      // Test club creation
      final studentToAssign = availableStudents.first;
      final createSuccess = await srmCtrl.createClub(
        name: 'AI & Data Science Club',
        description: 'Machine Learning and Data Analytics Society',
        category: 'technical',
        leaderUserId: studentToAssign.id,
      );

      expect(createSuccess, true);
      expect(srmCtrl.successMessage, contains('provisioned successfully'));
    });
  });
}
