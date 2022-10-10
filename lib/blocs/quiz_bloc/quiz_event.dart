part of 'quiz_bloc.dart';

@immutable
abstract class QuizEvent {}

class QuizThemeAndDifficultySelectEvent extends QuizEvent {
  final QuizTheme qTheme;
  final QuizDifficulty qDifficulty;

  QuizThemeAndDifficultySelectEvent(
      {required this.qTheme, required this.qDifficulty});
}

class QuizLoadQuestionsEvent extends QuizEvent {
  final QuizTheme qTheme;
  final QuizDifficulty qDifficulty;

  QuizLoadQuestionsEvent({required this.qTheme, required this.qDifficulty});
}

class QuizEndedEvent extends QuizEvent {}
