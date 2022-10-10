part of 'quiz_bloc.dart';

@immutable
abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizThemeAndDifficultySelectedState extends QuizState {
  final QuizTheme qTheme;
  final QuizDifficulty qDifficulty;

  QuizThemeAndDifficultySelectedState(
      {required this.qTheme, required this.qDifficulty});
}

class QuizLoadingQuestionsState extends QuizState {}

class QuizStartedState extends QuizState {
  final List<Question> questions;

  QuizStartedState({required this.questions});
}
