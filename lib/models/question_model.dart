class Question {
  final String question;
  final List<Answer> answers;
  final int correctAnswersCount;
  bool isComplete = false;
  int userAnswersCount = 0;

  Question({
    required this.question,
    required this.answers,
    required this.correctAnswersCount,
  });
}

class QuestionAnswers {
  final Answer? answerA;
  final Answer? answerB;
  final Answer? answerC;
  final Answer? answerD;
  final Answer? answerE;
  final Answer? answerF;

  QuestionAnswers(
      {this.answerA,
      this.answerB,
      this.answerC,
      this.answerD,
      this.answerE,
      this.answerF});
}

class Answer {
  final String text;
  final bool isCorrect;
  bool wasPressed = false;

  Answer({required this.text, required this.isCorrect});
}
