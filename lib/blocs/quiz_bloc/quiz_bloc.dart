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
  QuizBloc() : super(QuizInitial()) {
    on<QuizThemeAndDifficultySelectEvent>(onThemeAndDifficultySelect);
    on<QuizLoadQuestionsEvent>(onQuizLoadQuestions);
    on<UpdateLoadedQuestionsEvent>(onUpdateLoadedQuestions);
  }

  onThemeAndDifficultySelect(
      QuizThemeAndDifficultySelectEvent event, Emitter<QuizState> emit) async {
    emit(QuizThemeAndDifficultySelectedState(
        qTheme: event.qTheme, qDifficulty: event.qDifficulty));
  }

  onQuizLoadQuestions(
      QuizLoadQuestionsEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoadingQuestionsState());
    await Future.delayed(Duration(seconds: 1));
    final QuizAPIClient qAPI = QuizAPIClient();

    final questions =
        await qAPI.getQuestions(event.qTheme.name, event.qDifficulty.name);

    final parsedQuestions = parseQuestions(questions);
    inspect(parsedQuestions);
    // } catch (e) {
    //   ColorScheme colorScheme = Theme.of(context).colorScheme;
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     behavior: SnackBarBehavior.floating,
    //     backgroundColor: colorScheme.tertiaryContainer,
    //     elevation: 20,
    //     duration: const Duration(seconds: 1),
    //     content: Text(
    //       e.toString(),
    //       style: TextStyle(color: colorScheme.inverseSurface),
    //     ),
    //   ));
    //   // Navigator.of(context).pushReplacement(
    //   //   PageRouteBuilder(
    //   //     pageBuilder: (_, __, ___) => const HomeScreenWidget(),
    //   //     transitionDuration: const Duration(milliseconds: 300),
    //   //     transitionsBuilder: (_, a, __, c) =>
    //   //         FadeTransition(opacity: a, child: c),
    //   //   ),
    //   // );
    // }
    // }
    emit(QuizLoadedQuestionsState(
        questions: parsedQuestions, currentQuestion: 0));
  }

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
        bool isCorrect =
            q['correct_answers']['${k[entry.key]}_correct'] == 'true'
                ? true
                : false;
        return Answer(text: entry.value, isCorrect: isCorrect);
      }).toList();
      // List<Answer> asa = [];
      // for (var i in answers) {
      //   if (i) {
      //     asa.add(i);
      //   }
      // }
      int correctAnswersCount = 0;
      final List cA = q['correct_answers'].values.toList();
      for (var a in cA) {
        if (a == 'true') {
          correctAnswersCount += 1;
        }
      }
      answers.removeWhere((e) => e == null);
      parsedQuestions.add(Question(
          question: q['question'],
          answers: answers,
          correctAnswersCount: correctAnswersCount));
    }
    // inspect(parsedQuestions);
    return parsedQuestions;
  }

  onUpdateLoadedQuestions(
      UpdateLoadedQuestionsEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoadedQuestionsState(
        questions: event.questions, currentQuestion: event.currentQuestion));
  }
}
