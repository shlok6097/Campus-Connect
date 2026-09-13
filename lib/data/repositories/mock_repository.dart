import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/team_model.dart';
import '../models/club_model.dart';
import '../models/note_model.dart';
import '../models/game_model.dart';
import '../../core/constants/asset_constants.dart';

class MockRepository {
  static final MockRepository instance = MockRepository._internal();
  MockRepository._internal() {
    _initData();
  }

  // State caches
  late UserModel currentUser;
  late List<EventModel> events;
  late List<RegistrationModel> registrations;
  late List<TeamModel> teams;
  late List<ClubModel> clubs;
  late List<NoteModel> notes;
  late List<LeaderboardUser> leaderboard;
  late List<GameModel> games;

  void _initData() {
    currentUser = const UserModel(
      id: '',
      name: 'Student Member',
      email: '',
      accountType: AccountType.student,
      role: UserRole.studentMember,
    );

    events = <EventModel>[];
    registrations = <RegistrationModel>[];
    teams = <TeamModel>[];
    clubs = <ClubModel>[];
    notes = <NoteModel>[];
    leaderboard = <LeaderboardUser>[];
    games = _buildDefaultGames();
  }

  static List<GameModel> _buildDefaultGames() {
    return [
      const GameModel(
        id: 'game_debugger',
        title: 'Code Debugger',
        subtitle: 'Find and fix logic errors in 60s',
        category: GameCategory.coding,
        difficulty: 'Medium',
        playerCount: 142,
        timeLimitSeconds: 60,
        icon: 'bug_report',
        questions: [
          GameQuestion(
            id: 'q1',
            title: 'Identify the Memory / Logic Bug',
            prompt: 'In this Python binary search implementation, which line causes an infinite loop when the target is not present in the array?',
            codeSnippet: '''def binary_search(arr, target):
    low = 0
    high = len(arr) - 1
    
    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid        # <-- Bug here?
        else:
            high = mid - 1
            
    return -1''',
            options: [
              'Line 4: while low <= high should be while low < high',
              'Line 9: low = mid should be low = mid + 1',
              'Line 11: high = mid - 1 should be high = mid',
              'Line 5: (low + high) // 2 causes integer overflow',
            ],
            correctOptionIndex: 1,
            explanation: 'When arr[mid] < target, setting `low = mid` without adding 1 prevents the window from shrinking when low == high - 1, causing an infinite loop. The correct assignment is `low = mid + 1`.',
            points: 50,
          ),
          GameQuestion(
            id: 'q2',
            title: 'Pointer / Off-by-One in C++',
            prompt: 'What happens when this reverse string function is executed on `str = "UVCE"`?',
            codeSnippet: '''void reverse(char* s) {
    int len = strlen(s);
    for (int i = 0; i <= len / 2; i++) {
        char temp = s[i];
        s[i] = s[len - i];
        s[len - i] = temp;
    }
}''',
            options: [
              'Reverses correctly to "ECVU"',
              'Swaps null terminator \\0 into s[0], corrupting the string',
              'Segmentation fault on line 2',
              'Infinite loop in for condition',
            ],
            correctOptionIndex: 1,
            explanation: '`s[len - i]` on the first iteration (i=0) targets `s[len]`, which is the null terminator `\\0`. It should be `s[len - 1 - i]`.',
            points: 50,
          ),
        ],
      ),
      const GameModel(
        id: 'game_algo_race',
        title: 'Algorithm Race',
        subtitle: 'Solve time-complexity puzzles',
        category: GameCategory.cs,
        difficulty: 'Hard',
        playerCount: 88,
        timeLimitSeconds: 90,
        icon: 'speed',
      ),
      const GameModel(
        id: 'game_ai_quiz',
        title: 'AI & Neural Trivia',
        subtitle: 'Test your deep learning instincts',
        category: GameCategory.ai,
        difficulty: 'Easy',
        playerCount: 110,
        timeLimitSeconds: 45,
        icon: 'psychology',
      ),
      const GameModel(
        id: 'game_eng_quiz',
        title: 'Engineering Core Quiz',
        subtitle: 'Circuits, logic gates, & boolean math',
        category: GameCategory.engineering,
        difficulty: 'Medium',
        playerCount: 65,
        timeLimitSeconds: 60,
        icon: 'memory',
      ),
    ];
  }

  void seedMockDataForTesting() {
    // Current User: Rahul Kumar
    currentUser = const UserModel(
      id: 'usr_rahul',
      name: 'Rahul Kumar',
      email: 'rahul.kumar@uvce.edu',
      phone: '+91 98765 43210',
      studentId: 'UVCE21CS045',
      branch: 'Computer Science & Engineering',
      semester: 6,
      accountType: AccountType.student,
      role: UserRole.studentMember,
      avatarUrl: AssetConstants.avatarRahul,
      bio: 'Passionate Computer Science student with a strong interest in Artificial Intelligence and Machine Learning. I love solving complex problems and collaborating on innovative projects. Always eager to learn new technologies and build solutions that make an impact.',
      skills: ['Python', 'TensorFlow', 'React', 'Node.js', 'SQL', 'Git', 'Flutter'],
      lookingFor: ['Hackathons', 'AI/ML Projects', 'Open Source'],
      isAvailableForTeams: true,
      totalPoints: 850,
      contributionsCount: 18,
      achievements: [
        UserAchievement(
          title: 'Hackathon Winner',
          issuer: 'GDG DevFest 2023 - 1st Place',
          date: 'Nov 2023',
          icon: 'trophy',
        ),
        UserAchievement(
          title: 'AWS Certified Cloud Practitioner',
          issuer: 'Amazon Web Services',
          date: 'Jan 2024',
          icon: 'workspace_premium',
        ),
      ],
    );

    // Events
    events = [
      EventModel(
        id: 'evt_hack2026',
        title: 'Hackathon 2026',
        description: 'Join UVCE’s flagship 36-hour hackathon! Collaborate with top student developers, designers, and innovators to build cutting-edge solutions across AI, Web3, and Open Innovation. Mentorship from industry leaders, workshops, and ₹50,000+ in prize pool await!',
        category: EventCategory.hackathon,
        bannerUrl: AssetConstants.hackathonBanner,
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 16)),
        timeString: 'Oct 15, 9:00 AM – Oct 17, 6:00 PM',
        venue: 'Main Campus Auditorium & Innovation Hub',
        organizerName: 'GDG UVCE & Coding Club',
        maxParticipants: 200,
        registeredCount: 128,
        entryFee: 0.0,
        isFeatured: true,
        prizes: const [
          PrizeItem(rankTitle: '1st Place', amount: '₹25,000', description: 'Cash prize + GDG Swag kit + Fast-track internship opportunities.', icon: 'trophy'),
          PrizeItem(rankTitle: '2nd Place', amount: '₹15,000', description: 'Cash prize + Cloud credits + Certificate of Excellence.', icon: 'military_tech'),
          PrizeItem(rankTitle: '3rd Place', amount: '₹10,000', description: 'Cash prize + Premium dev subscriptions.', icon: 'emoji_events'),
        ],
        timeline: const [
          TimelineStep(title: 'Registrations Close', time: 'Oct 12, 11:59 PM', description: 'Team formations & problem statements released.'),
          TimelineStep(title: 'Opening Ceremony & Hacking Begins', time: 'Oct 15, 9:00 AM', description: 'Keynote and hacking timer starts.'),
          TimelineStep(title: 'Mentorship Rounds 1 & 2', time: 'Oct 16, 2:00 PM', description: 'Mid-way architecture checks with mentors.'),
          TimelineStep(title: 'Final Pitches & Awards', time: 'Oct 17, 4:00 PM', description: 'Live demos to industry judges & prize distribution.'),
        ],
        rules: const [
          'Teams must consist of 2 to 4 eligible university students.',
          'All code must be written during the 36-hour hackathon period.',
          'Open-source libraries and APIs are permitted with proper attribution.',
          'Projects must include a working demo and public Git repository.',
        ],
        eligibility: const [
          'Open to all undergraduate and postgraduate engineering students.',
          'Valid University ID card required during check-in.',
        ],
        customFormFields: const [
          CustomFormField(id: 'q_tshirt', label: 'T-Shirt Size', type: QuestionType.dropdown, options: ['S', 'M', 'L', 'XL', 'XXL']),
          CustomFormField(id: 'q_diet', label: 'Dietary Preferences', type: QuestionType.dropdown, options: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Jain']),
          CustomFormField(id: 'q_github', label: 'GitHub Profile Link', type: QuestionType.text, isRequired: true),
          CustomFormField(id: 'q_exp', label: 'Years of Development Experience', type: QuestionType.dropdown, options: ['< 1 Year', '1-2 Years', '3+ Years']),
        ],
      ),
      EventModel(
        id: 'evt_flutter_ws',
        title: 'Flutter & AI Workshop',
        description: 'Hands-on masterclass building production-grade Flutter apps integrated with Gemini 1.5 Flash models. Build full-stack apps in 4 hours.',
        category: EventCategory.workshop,
        bannerUrl: AssetConstants.workshopBanner,
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        timeString: 'Aug 28, 2:00 PM – 6:00 PM',
        venue: 'CS Seminar Hall',
        organizerName: 'Google Developer Group',
        maxParticipants: 80,
        registeredCount: 65,
        entryFee: 0.0,
        isFeatured: false,
      ),
      EventModel(
        id: 'evt_code_clash',
        title: 'Algorithmic Code Clash',
        description: 'Speed debugging and competitive algorithmic programming contest with live leaderboard and instant testcase evaluation.',
        category: EventCategory.technical,
        bannerUrl: AssetConstants.hackathonBanner,
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        timeString: 'Sep 05, 10:00 AM – 1:00 PM',
        venue: 'Online & Lab 3',
        organizerName: 'Coding Club UVCE',
        maxParticipants: 150,
        registeredCount: 92,
        entryFee: 0.0,
      ),
    ];

    // Registrations for Hackathon 2026
    registrations = List.generate(25, (index) {
      final names = [
        'Rahul Kumar', 'Ananya Sharma', 'Kiran Patil', 'Priya Rao', 'Arjun Singh',
        'Sneha Reddy', 'Vikram Desai', 'Rohan Gupta', 'Divya Nair', 'Karthik V',
        'Neha Joshi', 'Manoj Gowda', 'Aditi Kulkarni', 'Sanjay Bhat', 'Meera Pai',
        'Deepak Hegde', 'Pooja Naik', 'Harish Prabhu', 'Tanvi Shetty', 'Varun Rao',
        'Shweta Hegde', 'Naveen Kumar', 'Rashmi Kamath', 'Abhishek Jain', 'Preeti Shenoy'
      ];
      final branches = ['CSE', 'ISE', 'ECE', 'ME', 'EEE'];
      final name = names[index % names.length];
      final isConfirmed = index < 18;

      return RegistrationModel(
        id: 'REG-2026-${(1001 + index)}',
        eventId: 'evt_hack2026',
        eventTitle: 'Hackathon 2026',
        studentId: 'usr_$index',
        studentUSN: 'UVCE21CS${(index + 10).toString().padLeft(3, '0')}',
        studentName: name,
        studentEmail: '${name.toLowerCase().replaceAll(' ', '.')}@uvce.edu',
        studentPhone: '+91 98${index}01 23456',
        branch: branches[index % branches.length],
        semester: (index % 4 + 5), // 5th to 8th
        registrationDate: DateTime.now().subtract(Duration(days: index ~/ 2, hours: index * 2)),
        status: isConfirmed ? RegistrationStatus.confirmed : RegistrationStatus.pending,
        customResponses: {
          'T-Shirt Size': ['M', 'L', 'XL'][index % 3],
          'Dietary Preferences': ['Vegetarian', 'Non-Vegetarian'][index % 2],
          'GitHub Profile Link': 'https://github.com/${name.toLowerCase().replaceAll(' ', '')}',
        },
      );
    });

    // Teams
    teams = [
      TeamModel(
        id: 'team_nova',
        name: 'Team Nova',
        eventName: 'Hackathon 2026',
        eventId: 'evt_hack2026',
        leaderName: 'Rahul Kumar',
        leaderId: 'usr_rahul',
        members: const [
          TeamMemberItem(
            id: 'usr_rahul',
            name: 'Rahul Kumar',
            role: 'Team Leader • Backend',
            avatarUrl: AssetConstants.avatarRahul,
            branch: 'CSE',
            semester: 6,
            isLeader: true,
          ),
          TeamMemberItem(
            id: 'usr_ananya',
            name: 'Ananya Sharma',
            role: 'UI/UX Designer',
            avatarUrl: AssetConstants.avatarAnanya,
            branch: 'ISE',
            semester: 6,
          ),
          TeamMemberItem(
            id: 'usr_kiran',
            name: 'Kiran Patil',
            role: 'ML Engineer',
            avatarUrl: AssetConstants.avatarKiran,
            branch: 'ECE',
            semester: 6,
          ),
          TeamMemberItem(
            id: 'usr_priya',
            name: 'Priya Rao',
            role: 'Flutter Developer',
            avatarUrl: AssetConstants.avatarPriya,
            branch: 'CSE',
            semester: 6,
          ),
        ],
        project: const ProjectModel(
          id: 'proj_smart_campus',
          title: 'Smart Campus Assistant',
          problem: 'Students frequently struggle to navigate expansive university campuses, locate open study spaces, and access unified schedules without jumping between fragmented apps and noticeboards.',
          solution: 'Developing a unified cross-platform mobile application powered by real-time spatial positioning, AR indoor wayfinding, and an intelligent chatbot for campus resource booking.',
          category: 'AI / ML',
          stage: ProjectStage.development,
          techStack: ['Flutter', 'Firebase', 'Python', 'TensorFlow', 'FastAPI'],
          lookingForRoles: ['Frontend Tester', 'DevOps Specialist'],
          isPublic: true,
          imageUrl: AssetConstants.projectMockup,
        ),
        sharedFiles: const [
          SharedFileItem(
            id: 'file_1',
            title: 'Project Architecture & Report.pdf',
            fileType: FileType.pdf,
            fileSize: '2.4 MB',
            updatedTime: '2 hours ago',
            downloadUrl: '#',
          ),
          SharedFileItem(
            id: 'file_2',
            title: 'Demo Walkthrough Video',
            fileType: FileType.video,
            fileSize: '14.2 MB',
            updatedTime: '5 hours ago',
            downloadUrl: '#',
          ),
          SharedFileItem(
            id: 'file_3',
            title: 'GitHub Repository',
            fileType: FileType.code,
            fileSize: 'External Link',
            updatedTime: 'Yesterday',
            downloadUrl: 'https://github.com/team-nova/smart-campus',
          ),
        ],
        recentActivity: const [
          TeamActivityItem(
            id: 'act_1',
            userName: 'Rahul',
            userAvatar: AssetConstants.avatarRahul,
            actionText: 'updated the project description and milestones.',
            timeAgo: '2 hours ago',
          ),
          TeamActivityItem(
            id: 'act_2',
            userName: 'Ananya',
            userAvatar: AssetConstants.avatarAnanya,
            actionText: 'uploaded design prototype file (Project UI.pdf).',
            timeAgo: '5 hours ago',
          ),
          TeamActivityItem(
            id: 'act_3',
            userName: 'Rahul',
            userAvatar: AssetConstants.avatarRahul,
            actionText: 'invited Priya Rao to the team.',
            timeAgo: 'Yesterday',
          ),
        ],
      ),
      TeamModel(
        id: 'team_vision',
        name: 'AI Vision Team',
        eventName: 'Hackathon 2026',
        eventId: 'evt_hack2026',
        leaderName: 'Arjun Singh',
        leaderId: 'usr_arjun',
        members: const [
          TeamMemberItem(
            id: 'usr_arjun',
            name: 'Arjun Singh',
            role: 'Lead',
            avatarUrl: AssetConstants.defaultAvatar,
            branch: 'CSE',
            semester: 6,
            isLeader: true,
          ),
          TeamMemberItem(
            id: 'usr_sneha',
            name: 'Sneha Reddy',
            role: 'Computer Vision Dev',
            avatarUrl: AssetConstants.defaultAvatar,
            branch: 'ISE',
            semester: 6,
          ),
        ],
        project: const ProjectModel(
          id: 'proj_vision',
          title: 'Automated Attendance via CV',
          problem: 'Manual roll-calls waste valuable lecture time and are vulnerable to proxy attendance.',
          solution: 'Edge-AI face recognition cameras connected to faculty dashboards with instant USN matching.',
          category: 'AI / ML',
          stage: ProjectStage.planning,
          techStack: ['Python', 'OpenCV', 'PyTorch', 'React'],
          lookingForRoles: ['Backend Lead', 'UI Designer'],
          isPublic: true,
        ),
      ),
    ];

    // Clubs
    clubs = [
      ClubModel(
        id: 'club_coding',
        name: 'Coding Club',
        tagline: 'Learn, build, and deploy together',
        description: 'We are a community of passionate developers dedicated to learning, building, and sharing knowledge. From foundational workshops to intense hackathons, we provide the resources and environment to grow your technical skills. Join us to collaborate on real-world projects and connect with peers who share your drive for technology.',
        category: ClubCategory.technical,
        logoUrl: AssetConstants.codingClubLogo,
        memberCount: 245,
        isUserJoined: true,
        userRole: 'Member',
        buildingProjectTitle: 'Campus Navigation App',
        buildingProjectDesc: 'An interactive wayfinding solution helping students navigate the complex university campus with real-time routing.',
        buildingProjectTech: ['Flutter', 'Firebase', 'OpenStreetMap'],
        upcomingActivities: const [
          ClubActivityItem(id: 'act_c1', title: 'Flutter & Dart Workshop', description: 'Hands-on mobile development session', month: 'AUG', day: '28'),
          ClubActivityItem(id: 'act_c2', title: 'Algorithmic Contest #4', description: '3-hour competitive coding sprint', month: 'SEP', day: '02'),
          ClubActivityItem(id: 'act_c3', title: 'Open Source Hack Night', description: 'Contribute to campus repositories', month: 'SEP', day: '15'),
        ],
        achievements: const [
          'State-Level Hackathon Winner 2023',
          'Conducted 24 Workshops with 1,500+ Attendees',
          'Google Cloud Community of the Year',
        ],
        members: const [
          ClubMemberItem(
            id: 'usr_rahul',
            name: 'Rahul Kumar',
            role: 'Club President',
            branch: 'CSE',
            semester: 6,
            avatarUrl: AssetConstants.avatarRahul,
            joinedDate: '12 Aug 2023',
            isManager: true,
          ),
          ClubMemberItem(
            id: 'usr_ananya',
            name: 'Ananya Sharma',
            role: 'Event Manager',
            branch: 'ISE',
            semester: 6,
            avatarUrl: AssetConstants.avatarAnanya,
            joinedDate: '05 Jan 2024',
            isManager: true,
          ),
          ClubMemberItem(
            id: 'usr_kiran',
            name: 'Kiran Patil',
            role: 'Technical Lead',
            branch: 'ECE',
            semester: 6,
            avatarUrl: AssetConstants.avatarKiran,
            joinedDate: '18 Sep 2023',
            isManager: true,
          ),
          ClubMemberItem(
            id: 'usr_priya',
            name: 'Priya Rao',
            role: 'Member',
            branch: 'CSE',
            semester: 6,
            avatarUrl: AssetConstants.avatarPriya,
            joinedDate: '10 Feb 2024',
            isManager: false,
          ),
        ],
      ),
      ClubModel(
        id: 'club_ai',
        name: 'AI & Machine Learning Club',
        tagline: 'Pioneering intelligent systems on campus',
        description: 'Explore neural networks, LLMs, computer vision, and generative AI through research paper reading groups and real client projects.',
        category: ClubCategory.technical,
        logoUrl: AssetConstants.aiClubLogo,
        memberCount: 180,
        isUserJoined: false,
        userRole: 'None',
        buildingProjectTitle: 'University Question Bank AI',
        buildingProjectDesc: 'RAG-based search engine indexing 10 years of past exam papers and lecture notes.',
        buildingProjectTech: ['Python', 'LangChain', 'ChromaDB'],
        upcomingActivities: const [
          ClubActivityItem(id: 'act_ai1', title: 'GenAI Hackathon', description: 'Build agentic workflows in 24h', month: 'SEP', day: '10'),
        ],
        achievements: const ['Published 4 IEEE Student Papers in 2023'],
      ),
      ClubModel(
        id: 'club_design',
        name: 'Design & Creative Club',
        tagline: 'Where aesthetics meets functionality',
        description: 'Fostering UI/UX designers, 3D artists, and creative technologists through portfolio reviews and design sprints.',
        category: ClubCategory.creative,
        logoUrl: AssetConstants.codingClubLogo,
        memberCount: 120,
        isUserJoined: true,
        userRole: 'Co-Lead',
        buildingProjectTitle: 'Campus Design System',
        buildingProjectDesc: 'Unified Figma token library for student club posters and applications.',
        buildingProjectTech: ['Figma', 'CSS Tokens', 'Tailwind'],
        upcomingActivities: const [],
        achievements: const ['Best UI Design in Smart India Hackathon'],
      ),
    ];

    // Notes
    notes = [
      const NoteModel(
        id: 'note_trees',
        title: 'Data Structures — Trees & BST',
        description: 'Comprehensive lecture notes covering fundamental concepts of tree data structures, binary search trees (BST), AVL balance rotations, tree traversal algorithms (Inorder, Preorder, Postorder, Level-order), and complexity derivations.',
        subject: NoteSubject.dsa,
        authorName: 'Rahul Kumar',
        authorAvatar: AssetConstants.avatarRahul,
        course: 'CSE • 5th Sem',
        uploadDate: 'Oct 12, 2023',
        rating: 4.8,
        downloadCount: 150,
        fileFormat: 'PDF',
        fileSize: '2.4 MB',
        pageCount: 18,
        topicsCovered: [
          'Binary Trees Fundamentals',
          'Binary Search Trees (BST)',
          'AVL Trees & Self-Balancing',
          'Tree Traversals (BFS & DFS)',
          'Time & Space Complexity Proofs',
        ],
        tags: ['Midterm', 'Finals', 'Cheat Sheet', 'Lecture Notes'],
      ),
      const NoteModel(
        id: 'note_os',
        title: 'Operating Systems — Process Synchronization',
        description: 'Detailed analysis of semaphores, mutex locks, Deadlock handling with Banker’s Algorithm, and Classical IPC problems with complete C code snippets.',
        subject: NoteSubject.os,
        authorName: 'Ananya Sharma',
        authorAvatar: AssetConstants.avatarAnanya,
        course: 'ISE • 4th Sem',
        uploadDate: 'Nov 04, 2023',
        rating: 4.9,
        downloadCount: 210,
        fileFormat: 'PDF',
        fileSize: '3.1 MB',
        pageCount: 24,
        topicsCovered: [
          'Process Synchronization',
          'Critical Section Problem',
          'Semaphores & Mutexes',
          'Banker’s Algorithm for Deadlock',
        ],
        tags: ['Finals', 'Exam Notes'],
      ),
      const NoteModel(
        id: 'note_dbms',
        title: 'DBMS — Normalization & SQL Queries',
        description: 'Step-by-step breakdown of 1NF, 2NF, 3NF, BCNF with functional dependency closure algorithms and practical SQL queries.',
        subject: NoteSubject.dbms,
        authorName: 'Kiran Patil',
        authorAvatar: AssetConstants.avatarKiran,
        course: 'CSE • 5th Sem',
        uploadDate: 'Dec 01, 2023',
        rating: 4.7,
        downloadCount: 185,
        fileFormat: 'PDF',
        fileSize: '1.9 MB',
        pageCount: 15,
        topicsCovered: [
          'Functional Dependencies',
          'Normalization 1NF to BCNF',
          'Lossless Join Decomposition',
          'Complex SQL Joins',
        ],
        tags: ['Midterm', 'Cheat Sheet'],
      ),
    ];

    // Leaderboard
    leaderboard = const [
      LeaderboardUser(
        rank: 1,
        name: 'Rahul Kumar',
        branch: 'CS',
        semester: 6,
        avatarUrl: AssetConstants.avatarRahul,
        points: 850,
        contributionsCount: 18,
        isCurrentUser: true,
      ),
      LeaderboardUser(
        rank: 2,
        name: 'Ananya Sharma',
        branch: 'IT',
        semester: 6,
        avatarUrl: AssetConstants.avatarAnanya,
        points: 720,
        contributionsCount: 15,
      ),
      LeaderboardUser(
        rank: 3,
        name: 'Kiran Patil',
        branch: 'ECE',
        semester: 8,
        avatarUrl: AssetConstants.avatarKiran,
        points: 640,
        contributionsCount: 13,
      ),
      LeaderboardUser(
        rank: 4,
        name: 'Priya Rao',
        branch: 'CS',
        semester: 6,
        avatarUrl: AssetConstants.avatarPriya,
        points: 590,
        contributionsCount: 11,
      ),
      LeaderboardUser(
        rank: 5,
        name: 'Arjun Singh',
        branch: 'CS',
        semester: 6,
        avatarUrl: AssetConstants.defaultAvatar,
        points: 540,
        contributionsCount: 9,
      ),
    ];

    // Technical Games
    games = _buildDefaultGames();
  }

  // Repository Methods
  void addRegistration(RegistrationModel registration) {
    registrations.insert(0, registration);
    final eventIndex = events.indexWhere((e) => e.id == registration.eventId);
    if (eventIndex != -1) {
      events[eventIndex] = events[eventIndex].copyWith(
        registeredCount: events[eventIndex].registeredCount + 1,
      );
    }
  }

  void addEvent(EventModel event) {
    events.insert(0, event);
  }

  void addNote(NoteModel note) {
    notes.insert(0, note);
    currentUser = currentUser.copyWith(
      totalPoints: currentUser.totalPoints + 50,
      contributionsCount: currentUser.contributionsCount + 1,
    );
  }

  void joinClub(String clubId) {
    final index = clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      clubs[index] = clubs[index].copyWith(
        isUserJoined: true,
        userRole: 'Member',
        memberCount: clubs[index].memberCount + 1,
      );
    }
  }
}
