enum GameCategory { coding, cs, electronics, engineering, logic, ai }

class GameQuestion {
  final String id;
  final String title;
  final String prompt;
  final String codeSnippet;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int points;

  const GameQuestion({
    required this.id,
    required this.title,
    required this.prompt,
    required this.codeSnippet,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.points = 50,
  });
}

class GameModel {
  final String id;
  final String title;
  final String subtitle;
  final GameCategory category;
  final String difficulty; // e.g. "Medium", "Hard", "Easy"
  final int playerCount;
  final int timeLimitSeconds;
  final String icon;
  final List<GameQuestion> questions;

  const GameModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.difficulty,
    this.playerCount = 120,
    this.timeLimitSeconds = 300,
    this.icon = 'code',
    this.questions = const [],
  });
}

class GameLeaderboardEntry {
  final int rank;
  final String name;
  final String avatarUrl;
  final int score;
  final String timeTaken;

  const GameLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.timeTaken,
  });
}
