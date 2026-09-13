enum PublicationType {
  news,
  announcement,
  quiz,
  document,
  fact,
  poll,
  achievement,
  project,
  resource,
  report,
}

extension PublicationTypeExtension on PublicationType {
  String get displayName {
    switch (this) {
      case PublicationType.news:
        return 'News';
      case PublicationType.announcement:
        return 'Announcement';
      case PublicationType.quiz:
        return 'Quiz';
      case PublicationType.document:
        return 'Document';
      case PublicationType.fact:
        return 'Fact';
      case PublicationType.poll:
        return 'Poll';
      case PublicationType.achievement:
        return 'Achievement';
      case PublicationType.project:
        return 'Project';
      case PublicationType.resource:
        return 'Resource';
      case PublicationType.report:
        return 'Report';
    }
  }

  String get tag {
    return name.toUpperCase();
  }
}

class PublicationModel {
  final String id;
  final String? clubId;
  final String clubName;
  final PublicationType type;
  final String title;
  final String content;
  final Map<String, dynamic> metadata;
  final String authorName;
  final String? authorId;
  final int likesCount;
  final int viewsCount;
  final bool isPublished;
  final DateTime createdAt;

  const PublicationModel({
    required this.id,
    this.clubId,
    required this.clubName,
    required this.type,
    required this.title,
    this.content = '',
    this.metadata = const {},
    this.authorName = 'Club Leader',
    this.authorId,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.isPublished = true,
    required this.createdAt,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    PublicationType parseType(String? val) {
      if (val == null) return PublicationType.announcement;
      for (final t in PublicationType.values) {
        if (t.name.toLowerCase() == val.toLowerCase()) return t;
      }
      return PublicationType.announcement;
    }

    return PublicationModel(
      id: json['id'] as String? ?? 'pub_${DateTime.now().millisecondsSinceEpoch}',
      clubId: json['club_id'] as String?,
      clubName: json['club_name'] as String? ?? 'Club',
      type: parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
      authorName: json['author_name'] as String? ?? 'Club Leader',
      authorId: json['author_id'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (clubId != null) 'club_id': clubId,
      'club_name': clubName,
      'type': type.name,
      'title': title,
      'content': content,
      'metadata': metadata,
      'author_name': authorName,
      if (authorId != null) 'author_id': authorId,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PublicationModel copyWith({
    String? id,
    String? clubId,
    String? clubName,
    PublicationType? type,
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
    String? authorName,
    String? authorId,
    int? likesCount,
    int? viewsCount,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return PublicationModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
