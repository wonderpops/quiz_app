import 'package:quiz_app/models/question_model.dart';

class Quiz {
  QuizTheme? quizTheme;
  QuizDifficulty? quizDifficulty;
  List<Question> loadedQuestions = [];
  int compliteQuestionsCount = 0;
  int userScore = 0;

  loadQuestions(List questions) {
    // for (var q in questions) {
    //   final List k = q['answers'].keys.toList();
    //   List a = q['answers'].values.toList();
    //   List answers = a.asMap().entries.map((entry) {
    //     if (entry.value != null) {
    //       bool isCorrect =
    //           q['correct_answers']['${k[entry.key]}_correct'] == 'true'
    //               ? true
    //               : false;
    //       return Answer(text: entry.value, isCorrect: isCorrect);
    //     }
    //   }).toList();
    //   int correctAnswersCount = 0;
    //   final List cA = q['correct_answers'].values.toList();
    //   for (var a in cA) {
    //     if (a == 'true') {
    //       correctAnswersCount += 1;
    //     }
    //   }
    //   answers.removeWhere((e) => e == null);
    //   loadedQuestions.add(Question(
    //       question: q['question'],
    //       answers: answers,
    //       correctAnswersCount: correctAnswersCount));
    // }
    // // inspect(loadedQuestions);
  }

  Quiz({this.quizTheme, this.quizDifficulty});
}

class QuizTheme {
  String name;

  QuizTheme({required this.name});
}

class QuizDifficulty {
  String name;

  QuizDifficulty({required this.name});
}

List<QuizTheme> quizThemes = [
  QuizTheme(name: 'Linux'),
  QuizTheme(name: 'DevOps'),
  QuizTheme(name: 'Docker'),
  QuizTheme(name: 'Bash'),
  QuizTheme(name: 'SQL'),
  QuizTheme(name: 'CMS'),
  QuizTheme(name: 'Code'),
  QuizTheme(name: 'Uncategorized'),
];

List<QuizDifficulty> quizDifficulty = [
  QuizDifficulty(name: 'Easy'),
  QuizDifficulty(name: 'Medium'),
  QuizDifficulty(name: 'Hard'),
];
