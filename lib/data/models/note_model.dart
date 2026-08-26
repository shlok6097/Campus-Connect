enum NoteSubject { dsa, dbms, os, cn, ai, math, web }

class NoteModel {
  final String id;
  final String title;
  final String description;
  final NoteSubject subject;
  final String authorName;
  final String authorAvatar;
  final String course; // e.g. "CSE • 5th Sem"
  final String uploadDate;
  final double rating;
  final int downloadCount;
  final String fileFormat; // e.g. "PDF"
  final String fileSize;   // e.g. "2.4 MB"
  final int pageCount;
  final List<String> topicsCovered;
  final List<String> tags;
  final String fileUrl;

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.authorName,
    required this.authorAvatar,
    required this.course,
    required this.uploadDate,
    this.rating = 4.8,
    this.downloadCount = 0,
    this.fileFormat = 'PDF',
    this.fileSize = '2.4 MB',
    this.pageCount = 18,
    this.topicsCovered = const [],
    this.tags = const [],
    this.fileUrl = '',
  });
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String branch;
  final int semester;
  final String avatarUrl;
  final int points;
  final int contributionsCount;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.branch,
    required this.semester,
    required this.avatarUrl,
    required this.points,
    required this.contributionsCount,
    this.isCurrentUser = false,
  });
}
