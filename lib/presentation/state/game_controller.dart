import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/game_model.dart';
import '../../data/repositories/mock_repository.dart';

class GameController extends ChangeNotifier {
  static final GameController instance = GameController._internal();
  GameController._internal();

  final MockRepository _repo = MockRepository.instance;

  GameCategory? _selectedCategory;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasSubmittedAnswer = false;
  bool _isAnswerCorrect = false;
  int _score = 0;
  int _secondsRemaining = 60;
  Timer? _timer;

  GameCategory? get selectedCategory => _selectedCategory;
  List<GameModel> get games => _repo.games;
  GameModel get codeDebugger {
    if (_repo.games.isEmpty) {
      return const GameModel(
        id: 'game_debugger',
        title: 'Code Debugger',
        subtitle: 'Find and fix logic errors in 60s',
        category: GameCategory.coding,
        difficulty: 'Medium',
      );
    }
    return _repo.games.firstWhere(
      (g) => g.id == 'game_debugger',
      orElse: () => _repo.games.first,
    );
  }

  int get currentQuestionIndex => _currentQuestionIndex;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get hasSubmittedAnswer => _hasSubmittedAnswer;
  bool get isAnswerCorrect => _isAnswerCorrect;
  int get score => _score;
  int get secondsRemaining => _secondsRemaining;

  GameQuestion? get currentQuestion {
    final qList = codeDebugger.questions;
    if (qList.isNotEmpty && _currentQuestionIndex < qList.length) {
      return qList[_currentQuestionIndex];
    }
    return null;
  }

  void setCategoryFilter(GameCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void startSession(int timeLimit) {
    _currentQuestionIndex = 0;
    _selectedOptionIndex = null;
    _hasSubmittedAnswer = false;
    _isAnswerCorrect = false;
    _score = 0;
    _secondsRemaining = timeLimit;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void selectOption(int index) {
    if (_hasSubmittedAnswer) return;
    _selectedOptionIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedOptionIndex == null || _hasSubmittedAnswer) return;
    _hasSubmittedAnswer = true;
    final q = currentQuestion;
    if (q != null && _selectedOptionIndex == q.correctOptionIndex) {
      _isAnswerCorrect = true;
      _score += q.points;
      // Update global user points
      _repo.currentUser = _repo.currentUser.copyWith(
        totalPoints: _repo.currentUser.totalPoints + q.points,
      );
    } else {
      _isAnswerCorrect = false;
    }
    notifyListeners();
  }

  void nextQuestion() {
    final qList = codeDebugger.questions;
    if (_currentQuestionIndex < qList.length - 1) {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _hasSubmittedAnswer = false;
      _isAnswerCorrect = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
