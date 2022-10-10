import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/models/quiz_model.dart';

import '../../domain/quiz_api_client.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  late QuizTheme _quizTheme;
  late QuizDifficulty _quizDifficulty;

  QuizBloc() : super(QuizInitial()) {
    on<QuizThemeAndDifficultySelectEvent>(onThemeAndDifficultySelect);
    on<QuizLoadQuestionsEvent>(onQuizLoadQuestions);
    on<QuizEndedEvent>(onQuizEnded);
  }

  onThemeAndDifficultySelect(
      QuizThemeAndDifficultySelectEvent event, Emitter<QuizState> emit) async {
    _quizTheme = event.qTheme;
    _quizDifficulty = event.qDifficulty;
    emit(QuizThemeAndDifficultySelectedState(
        qTheme: event.qTheme, qDifficulty: event.qDifficulty));
  }

  onQuizLoadQuestions(
      QuizLoadQuestionsEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoadingQuestionsState());

    List<Question> questions = [];
    final QuizAPIClient qAPI = QuizAPIClient();

    final receivedQuestions =
        await qAPI.getQuestions(_quizTheme.name, _quizDifficulty.name);

    questions = parseQuestions(receivedQuestions);

    emit(QuizStartedState(questions: questions));
  }

  onQuizEnded(QuizEndedEvent event, Emitter<QuizState> emit) async {
    emit(QuizEndedState(
      questions: event.questions,
      qTheme: _quizTheme,
      qDifficulty: _quizDifficulty,
      userScore: event.userScore,
    ));
  }
}

//* not in block
List<Question> parseQuestions(List questions) {
  List<Question> parsedQuestions = [];
  for (var q in questions) {
    final List k = q['answers'].keys.toList();
    List a = q['answers'].values.toList();
    List aa = [];
    for (var i in a) {
      if (i != null) {
        aa.add(i);
      }
    }
    List<Answer> answers = aa.asMap().entries.map<Answer>((entry) {
      bool isCorrect = q['correct_answers']['${k[entry.key]}_correct'] == 'true'
          ? true
          : false;
      return Answer(text: entry.value, isCorrect: isCorrect);
    }).toList();

    int correctAnswersCount = 0;
    final List cA = q['correct_answers'].values.toList();
    for (var a in cA) {
      if (a == 'true') {
        correctAnswersCount += 1;
      }
    }

    parsedQuestions.add(Question(
        question: q['question'],
        answers: answers,
        correctAnswersCount: correctAnswersCount));
  }
  return parsedQuestions;
}
