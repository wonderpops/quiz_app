import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/blocs/quiz_bloc/quiz_bloc.dart';
import 'package:quiz_app/screens/quiz_screen/quiz_screen.dart';

import '../../models/quiz_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.background,
      statusBarIconBrightness:
          Theme.of(context).colorScheme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
      systemNavigationBarColor: Theme.of(context).colorScheme.background,
    ));

    final String greetingText;
    final int thisHour = DateTime.now().hour;

    if ((thisHour >= 0) && (thisHour < 6)) {
      greetingText = 'Nighty night!';
    } else if ((thisHour >= 6) && (thisHour < 12)) {
      greetingText = 'Lovely morning!';
    } else if ((thisHour >= 12) && (thisHour < 18)) {
      greetingText = 'Wonderful day!';
    } else if ((thisHour >= 18) && (thisHour < 24)) {
      greetingText = 'Fine evening!';
    } else {
      greetingText = 'Hey there!';
    }

    return SafeArea(
        child: Scaffold(
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  greetingText,
                  style: const TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you ready for quiz?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _ThemeAndDifficultySelectorsWisget(),
            const SizedBox(height: 32),
            _BeginButtonWidget(),
          ],
        ),
      ),
    ));
  }
}

class _ThemeAndDifficultySelectorsWisget extends StatefulWidget {
  _ThemeAndDifficultySelectorsWisget({super.key});
  dynamic qTheme;
  dynamic qDifficulty;

  @override
  State<_ThemeAndDifficultySelectorsWisget> createState() =>
      _ThemeAndDifficultySelectorsWisgetState();
}

class _ThemeAndDifficultySelectorsWisgetState
    extends State<_ThemeAndDifficultySelectorsWisget> {
  onSelectFieldChange(item) {
    switch (item.runtimeType) {
      case QuizTheme:
        widget.qTheme = item;
        break;
      case QuizDifficulty:
        widget.qDifficulty = item;
        break;
    }
    if ((widget.qTheme != null) && (widget.qDifficulty != null)) {
      QuizBloc qBloc = BlocProvider.of(context);
      qBloc.add(QuizThemeAndDifficultySelectEvent(
          qTheme: widget.qTheme, qDifficulty: widget.qDifficulty));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        DropdownButtonFormField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: colorScheme.tertiaryContainer)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: colorScheme.tertiaryContainer),
              ),
              labelText: 'Choose quiz theme',
              hintText: 'Linux',
            ),
            items: quizThemes
                .map((theme) =>
                    DropdownMenuItem(value: theme, child: Text(theme.name)))
                .toList(),
            onChanged: onSelectFieldChange),
        const SizedBox(height: 32),
        DropdownButtonFormField(
            decoration: InputDecoration(
              // hintStyle: TextStyle(color: light.withOpacity(.4)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: colorScheme.tertiaryContainer)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: colorScheme.tertiaryContainer),
              ),
              labelText: 'Choose quiz difficulty',
              hintText: 'Easy',
            ),
            items: quizDifficulty
                .map((theme) =>
                    DropdownMenuItem(value: theme, child: Text(theme.name)))
                .toList(),
            onChanged: onSelectFieldChange),
      ],
    );
  }
}

class _BeginButtonWidget extends StatefulWidget {
  _BeginButtonWidget({super.key});

  @override
  State<_BeginButtonWidget> createState() => _BeginButtonWidgetState();
}

class _BeginButtonWidgetState extends State<_BeginButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    _animController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizStartedState) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => QuizScreenWidget(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ),
          );
        }
      },
      builder: (context, state) {
        return AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              switch (state.runtimeType) {
                case QuizThemeAndDifficultySelectedState:
                  _animController.forward();
                  return Stack(
                    children: [
                      Builder(builder: (context) {
                        return Center(
                          child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(
                                    0.3 + 0.7 * _animController.value),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(child: Text("Let's begin!"))),
                        );
                      }),
                      Material(
                        color: Colors.transparent,
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              QuizBloc qBloc = BlocProvider.of(context);

                              qBloc.add(QuizLoadQuestionsEvent(
                                  qTheme: (state
                                          as QuizThemeAndDifficultySelectedState)
                                      .qTheme,
                                  qDifficulty: (state
                                          as QuizThemeAndDifficultySelectedState)
                                      .qDifficulty));
                              // // quiz.loadedQuestions = [];
                              // // quiz.compliteQuestionsCount = 0;
                              // // quiz.userScore = 0;

                              // if (quiz.quizTheme == null) {
                              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //     behavior: SnackBarBehavior.floating,
                              //     backgroundColor: colorScheme.tertiaryContainer,
                              //     elevation: 20,
                              //     duration: const Duration(seconds: 2),
                              //     content: Text(
                              //       "You need to select quiz theme before",
                              //       style: TextStyle(color: colorScheme.inverseSurface),
                              //     ),
                              //   ));
                              //   return;
                              // }
                              // if (quiz.quizDifficulty == null) {
                              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //     behavior: SnackBarBehavior.floating,
                              //     backgroundColor: colorScheme.tertiaryContainer,
                              //     elevation: 20,
                              //     duration: const Duration(seconds: 1),
                              //     content: Text(
                              //       "You need to select quiz difficulty before",
                              //       style: TextStyle(color: colorScheme.inverseSurface),
                              //     ),
                              //   ));
                              //   return;
                              // }

                              // Navigator.of(context).push(
                              //   PageRouteBuilder(
                              //     pageBuilder: (_, __, ___) => QuizScreenWidget(quiz: quiz),
                              //     transitionDuration: const Duration(milliseconds: 300),
                              //     transitionsBuilder: (_, a, __, c) =>
                              //         FadeTransition(opacity: a, child: c),
                              //   ),
                              // );
                            },
                            splashColor:
                                colorScheme.tertiaryContainer.withOpacity(.2),
                            hoverColor:
                                colorScheme.tertiaryContainer.withOpacity(.2),
                            borderRadius: BorderRadius.circular(20),
                            child: const SizedBox(
                              height: 50,
                              width: 200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                case QuizLoadingQuestionsState:
                case QuizStartedState:
                  _animController.reverse();
                  // print(_animController.value);
                  return Center(
                    child: Hero(
                      tag: 'loading_questions',
                      child: Material(
                        child: Container(
                            height: 50,
                            width: 200 - 150 * (1 - _animController.value),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                  20 + 10 * (1 - _animController.value)),
                            ),
                            child: const Center(
                                child: CircularProgressIndicator())),
                      ),
                    ),
                  );
                default:
                  return Hero(
                    tag: 'loading_questions',
                    child: Material(
                      child: Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                              child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: AutoSizeText(
                              "Select theme and difficulty",
                              minFontSize: 5,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ))),
                    ),
                  );
              }
            });
      },
    );
  }
}
