part of 'quiz_bloc.dart';

@immutable
abstract class QuizEvent {}

class QuizThemeAndDifficultySelectEvent extends QuizEvent {
  final QuizTheme qTheme;
  final QuizDifficulty qDifficulty;

  QuizThemeAndDifficultySelectEvent(
      {required this.qTheme, required this.qDifficulty});
}

class QuizLoadQuestionsEvent extends QuizEvent {}

class QuizEndedEvent extends QuizEvent {
  final List<Question> questions;
  final int userScore;

  QuizEndedEvent({required this.questions, required this.userScore});
}
