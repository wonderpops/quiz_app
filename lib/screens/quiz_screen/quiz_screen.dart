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

class _QuizScreenWidgetState extends State<QuizScreenWidget>
    with AnimationMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    QuizBloc qBloc = BlocProvider.of<QuizBloc>(context);
    QuizLoadedQuestionsState qBlocState =
        qBloc.state as QuizLoadedQuestionsState;

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
                              'Question ${qBlocState.currentQuestion + 1}/${qBlocState.questions.length}',
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
                                onPageChanged: (i) {
                                  qBlocState.currentQuestion = i;

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
                                    .questions[qBlocState.currentQuestion]
                                    .answers,
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
  const _AWidget({
    super.key,
    required this.answers,
  });
  final List<Answer> answers;

  @override
  State<_AWidget> createState() => _AWidgetState();
}

class _AWidgetState extends State<_AWidget> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List<Widget> getAnswerWidgets(List<Answer> answers, Duration duration) {
    List<Widget> answerWidgets = [];
    for (var i = 0; i < answers.length; i++) {
      answerWidgets.add(_AAW(
        answer: answers[i],
        delay: Duration(milliseconds: i * 100 + 100),
        duration: duration,
      ));
    }
    return answerWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: getAnswerWidgets(
                widget.answers, const Duration(milliseconds: 300)),
          )),
    );
  }
}

class _AAW extends StatefulWidget {
  const _AAW(
      {super.key,
      required this.answer,
      required this.delay,
      required this.duration});
  final Answer answer;
  final Duration delay;
  final Duration duration;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 80,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.tertiaryContainer.withOpacity(.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: AutoSizeText(
                  widget.answer.text,
                  minFontSize: 16,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionWidget extends StatefulWidget {
  const _QuestionWidget({
    super.key,
    required this.quiz,
  });
  final Quiz quiz;

  @override
  State<_QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<_QuestionWidget> {
  late PageController _carouselPageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _carouselPageController =
        PageController(initialPage: _currentPage, viewportFraction: 0.6);
  }

  @override
  void dispose() {
    super.dispose();
    _carouselPageController.dispose();
  }

  toNextPage() {
    // print('${_currentPage} ${widget.quiz.loadedQuestions.length}');
    if (widget.quiz.compliteQuestionsCount ==
        widget.quiz.loadedQuestions.length) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResultsScreenWidget(quiz: widget.quiz),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
      return;
    }
    if (_currentPage + 1 != widget.quiz.loadedQuestions.length) {
      _carouselPageController.animateToPage(_currentPage + 1,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double getScale(int index) {
      double value = 0;
      if (_carouselPageController.position.haveDimensions) {
        if (index.toDouble() > (_carouselPageController.page ?? 0)) {
          value = (0.5 /
                  ((_carouselPageController.page ?? 0) - index.toDouble())
                      .abs()) +
              0.25;
        } else if (index.toDouble() < (_carouselPageController.page ?? 0)) {
          value = (0.5 /
                  (((_carouselPageController.page ?? 0) - index.toDouble()) *
                          -1)
                      .abs()) +
              0.25;
        } else {
          value = (_carouselPageController.page ?? 0) + index.toDouble() == 0
              ? 1
              : index.toDouble();
        }
        // value = (_carouselPageController.page ?? 0) - index.toDouble() + 1;
        value = (value).clamp(0.5, 1);
      } else if (index.toDouble() == 0) {
        value = 1;
      } else {
        value = 0.75;
      }
      // print("value $value index $index");
      return value.abs();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Question ${_currentPage + 1}/${widget.quiz.loadedQuestions.length}',
            style: const TextStyle(fontSize: 32),
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          flex: 4,
          child: PageView.builder(
            itemCount: widget.quiz.loadedQuestions.length,
            controller: _carouselPageController,
            onPageChanged: (value) {
              _currentPage = value;
              setState(() {});
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                  animation: _carouselPageController,
                  builder: (context, child) {
                    double scale = getScale(index);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: scale == 1 ? 1 : scale - 0.5,
                        child: Column(
                          children: [
                            Card(
                              elevation: 5,
                              color: colorScheme.primaryContainer,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: SizedBox(
                                height: 250,
                                width: double.maxFinite,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Visibility(
                                        visible: widget
                                                .quiz
                                                .loadedQuestions[index]
                                                .correctAnswersCount >
                                            1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: colorScheme.onPrimary),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.info_outline),
                                                const SizedBox(width: 8),
                                                Text(
                                                    'Choose ${widget.quiz.loadedQuestions[index].correctAnswersCount} answers'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                          visible: widget
                                                  .quiz
                                                  .loadedQuestions[index]
                                                  .correctAnswersCount >
                                              1,
                                          child: const SizedBox(height: 16)),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.quiz.loadedQuestions[index]
                                                  .question,
                                              style: TextStyle(
                                                  fontSize: widget
                                                              .quiz
                                                              .loadedQuestions[
                                                                  index]
                                                              .question
                                                              .length >
                                                          50
                                                      ? 14
                                                      : 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Flexible(
                              flex: 3,
                              child: _AnswersWidget(
                                  quiz: widget.quiz,
                                  index: index,
                                  pageController: _carouselPageController,
                                  toNextPage: toNextPage),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ],
    );
  }
}

class _AnswersWidget extends StatefulWidget {
  _AnswersWidget(
      {super.key,
      required this.quiz,
      required this.index,
      required this.pageController,
      required this.toNextPage});
  final Quiz quiz;
  int index;
  final PageController pageController;
  final Function toNextPage;

  @override
  State<_AnswersWidget> createState() => _AnswersWidgetState();
}

class _AnswersWidgetState extends State<_AnswersWidget>
    with SingleTickerProviderStateMixin {
  int userAnswersCount = 0;

  addAnswerScore(int score) {
    userAnswersCount += 1;

    if (score > 0) {
      widget.quiz.loadedQuestions[widget.index].userCorrectAnswersCount += 1;
    }

    widget.quiz.userScore += score;
    // print(
    //     'Question index: ${widget.index} $userAnswersCount, ${widget.quiz.loadedQuestions[widget.index].correctAnswersCount}');
    if (userAnswersCount ==
        widget.quiz.loadedQuestions[widget.index].correctAnswersCount) {
      userAnswersCount = 0;
      widget.quiz.compliteQuestionsCount += 1;
      widget.quiz.loadedQuestions[widget.index].isComplete = true;
      widget.toNextPage();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widget.quiz.loadedQuestions[widget.index].answers
                .map((a) => _Answer(
                      answer: a,
                      isComplite:
                          widget.quiz.loadedQuestions[widget.index].isComplete,
                      addAnswerScore: addAnswerScore,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Answer extends StatefulWidget {
  _Answer(
      {super.key,
      required this.answer,
      required this.isComplite,
      required this.addAnswerScore});
  Answer answer;
  bool isChosen = false;
  final bool isComplite;
  final Function addAnswerScore;

  @override
  State<_Answer> createState() => __AnswerState();
}

class __AnswerState extends State<_Answer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          if (!widget.isComplite) {
            if (!widget.answer.wasPressed) {
              widget.answer.wasPressed = true;
              if (widget.answer.isCorrect) {
                widget.addAnswerScore(10);
              } else {
                widget.addAnswerScore(-10);
              }
              setState(() {});
            }
          }
        },
        child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: widget.answer.wasPressed
                  ? widget.answer.isCorrect
                      ? Colors.green.withOpacity(.8)
                      : Colors.red.withOpacity(.8)
                  : Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.answer.text,
                textAlign: TextAlign.center,
              ),
            ))),
      ),
    );
  }
}
