import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/quiz_api_client.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/screens/home_screen/home_screen.dart';
import 'package:quiz_app/screens/results_screen/results_screen.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../animations/fade_in.dart';
import '../../blocs/quiz_bloc/quiz_bloc.dart';

class QuizScreenWidget extends StatefulWidget {
  const QuizScreenWidget({super.key});

  @override
  State<QuizScreenWidget> createState() => _QuizScreenWidgetState();
}

class _QuizScreenWidgetState extends State<QuizScreenWidget> {
  int currentQuestionIndex = 0;
  late QuizBloc qBloc;
  late QuizStartedState qBlocState;
  late PageController pageController;

  @override
  void initState() {
    qBloc = BlocProvider.of<QuizBloc>(context);
    qBlocState = qBloc.state as QuizStartedState;

    pageController = PageController();
    super.initState();
  }

  checkAnswer(Answer answer) {
    Question currentQuestion = qBlocState.questions[currentQuestionIndex];
    currentQuestion.userAnswersCount += 1;
    if (currentQuestion.userAnswersCount <
        currentQuestion.correctAnswersCount) {
      if (!answer.isCorrect) {
        qBloc.userScore -= currentQuestion.correctAnswersCount == 1 ? 100 : 50;
      }
    } else {
      currentQuestion.isComplete = true;
      moveToNextNotAnsweredQuestion();
    }
  }

  moveToQuestion(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  moveToNextNotAnsweredQuestion() {
    if ((currentQuestionIndex + 1 < qBloc.questions.length)) {
      if (!qBlocState.questions[currentQuestionIndex + 1].isComplete) {
        moveToQuestion(currentQuestionIndex + 1);
        return;
      }
    }
    int index = -1;
    for (var i = 0; i < qBloc.questions.length; i++) {
      if (!qBloc.questions[i].isComplete) {
        moveToQuestion(i);
        return;
      }
    }
    if (index == -1) {
      endQuiz();
    }
  }

  endQuiz() {
    print('Quiz ended');
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
        child: Scaffold(
            extendBody: true,
            body: Hero(
              tag: 'loading_questions',
              flightShuttleBuilder: ((flightContext, animation, flightDirection,
                  fromHeroContext, toHeroContext) {
                animation.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    // the end of hero animation end

                  }
                });
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer.withOpacity(.4),
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                );
              }),
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(.4),
                        borderRadius: BorderRadius.circular(46),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: AutoSizeText(
                              'Question ${currentQuestionIndex + 1}/${qBlocState.questions.length}',
                              minFontSize: 30,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: PageView.builder(
                                controller: pageController,
                                onPageChanged: (i) {
                                  currentQuestionIndex = i;

                                  setState(() {});
                                },
                                itemCount: qBlocState.questions.length,
                                itemBuilder: (context, index) {
                                  return _QWidget(
                                    questionText:
                                        qBlocState.questions[index].question,
                                  );
                                }),
                          ),
                          Flexible(
                              flex: 2,
                              child: _AWidget(
                                answers: qBlocState
                                    .questions[currentQuestionIndex].answers,
                                checkAnswer: checkAnswer,
                              ))
                        ],
                      )),
                ),
              ),
            )));
  }
}

class _QWidget extends StatelessWidget {
  const _QWidget({super.key, required this.questionText});
  final String questionText;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: AutoSizeText(
              questionText,
              minFontSize: 24,
              maxLines: 4,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _AWidget extends StatefulWidget {
  const _AWidget({super.key, required this.answers, required this.checkAnswer});
  final List<Answer> answers;
  final Function checkAnswer;

  @override
  State<_AWidget> createState() => _AWidgetState();
}

class _AWidgetState extends State<_AWidget> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ListView.builder(
            itemCount: widget.answers.length,
            itemBuilder: ((context, i) => _AAW(
                  answer: widget.answers[i],
                  delay: Duration(milliseconds: i * 50 + 50),
                  duration: const Duration(milliseconds: 200),
                  checkAnswer: widget.checkAnswer,
                )),
          )),
    );
  }
}

class _AAW extends StatefulWidget {
  const _AAW({
    super.key,
    required this.answer,
    required this.delay,
    required this.duration,
    required this.checkAnswer,
  });
  final Answer answer;
  final Duration delay;
  final Duration duration;
  final Function checkAnswer;

  @override
  State<_AAW> createState() => _AAWState();
}

class _AAWState extends State<_AAW> with AnimationMixin {
  late AnimationController offsetController;
  late AnimationController opacityController;

  late Animation<double> offsetY;
  late Animation<double> opacity;

  @override
  void initState() {
    offsetController = createController();
    opacityController = createController();

    offsetY = Tween<double>(begin: 30, end: 0).animate(offsetController);
    opacity = Tween<double>(begin: 0, end: 1).animate(opacityController);

    Future.delayed(widget.delay).then((value) {
      offsetController.play(duration: widget.duration);
      opacityController.play(duration: widget.duration);
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _AAW oldWidget) {
    offsetController = createController();
    opacityController = createController();

    offsetY = Tween<double>(begin: 30, end: 0).animate(offsetController);
    opacity = Tween<double>(begin: 0, end: 1).animate(opacityController);

    Future.delayed(widget.delay).then((value) {
      offsetController.play(duration: widget.duration);
      opacityController.play(duration: widget.duration);
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: opacity.value,
      child: Transform.translate(
        offset: Offset(0, offsetY.value),
        child: GestureDetector(
          onTap: (() {
            if (!widget.answer.wasPressed) {
              widget.answer.wasPressed = true;
              setState(() {});
              widget.checkAnswer(widget.answer);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 80,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.answer.wasPressed
                    ? widget.answer.isCorrect
                        ? Colors.green.withOpacity(.8)
                        : Colors.red.withOpacity(.8)
                    : colorScheme.tertiaryContainer.withOpacity(.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: AutoSizeText(
                    widget.answer.text,
                    minFontSize: 16,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
