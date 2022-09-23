import 'package:quiz_app/models/question_model.dart';

class Quiz {
  QuizTheme? quizTheme;
  QuizDifficulty? quizDifficulty;
  List<Question> loadedQuestions = [];
  int compliteQuestionsCount = 0;
  int userScore = 0;

  loadQuestions(List questions) {
    for (var q in questions) {
      final List k = q['answers'].keys.toList();
      List a = q['answers'].values.toList();
      List answers = a.asMap().entries.map((entry) {
        if (entry.value != null) {
          bool isCorrect =
              q['correct_answers']['${k[entry.key]}_correct'] == 'true'
                  ? true
                  : false;
          return Answer(text: entry.value, isCorrect: isCorrect);
        }
      }).toList();
      int correctAnswersCount = 0;
      final List cA = q['correct_answers'].values.toList();
      for (var a in cA) {
        if (a == 'true') {
          correctAnswersCount += 1;
        }
      }
      answers.removeWhere((e) => e == null);
      loadedQuestions.add(Question(
          question: q['question'],
          answers: answers,
          correctAnswersCount: correctAnswersCount));
    }
    // inspect(loadedQuestions);
  }

  Quiz({this.quizTheme, this.quizDifficulty});
}

class QuizTheme {
  String name;
  ThemeType theme;

  QuizTheme({required this.name, required this.theme});
}

class QuizDifficulty {
  String name;
  Difficulty difficulty;

  QuizDifficulty({required this.name, required this.difficulty});
}

enum ThemeType {
  none,
  linux,
  devOps,
  docker,
  bash,
  sql,
  cms,
  code,
  uncategorized
}

enum Difficulty { easy, medium, hard }

List<QuizTheme> quizThemes = [
  QuizTheme(name: 'Linux', theme: ThemeType.linux),
  QuizTheme(name: 'DevOps', theme: ThemeType.devOps),
  QuizTheme(name: 'Docker', theme: ThemeType.docker),
  QuizTheme(name: 'Bash', theme: ThemeType.bash),
  QuizTheme(name: 'SQL', theme: ThemeType.sql),
  QuizTheme(name: 'CMS', theme: ThemeType.cms),
  QuizTheme(name: 'Code', theme: ThemeType.code),
  QuizTheme(name: 'Uncategorized', theme: ThemeType.uncategorized),
];

List<QuizDifficulty> quizDifficulty = [
  QuizDifficulty(name: 'Easy', difficulty: Difficulty.easy),
  QuizDifficulty(name: 'Medium', difficulty: Difficulty.medium),
  QuizDifficulty(name: 'Hard', difficulty: Difficulty.hard),
];
