import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/screens/quiz_screen/quiz_screen.dart';

import '../../models/quiz_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  final quiz = Quiz();

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
            _ThemeAndDifficultySelectorsWisget(quiz: quiz),
            const SizedBox(height: 32),
            _BeginButtonWidget(quiz: quiz),
          ],
        ),
      ),
    ));
  }
}

class _ThemeAndDifficultySelectorsWisget extends StatelessWidget {
  _ThemeAndDifficultySelectorsWisget({super.key, required this.quiz});
  final Quiz quiz;

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
                .map((theme) => DropdownMenuItem(
                    value: theme.theme, child: Text(theme.name)))
                .toList(),
            onChanged: (theme) {
              quiz.quizTheme =
                  quizThemes.firstWhere((qTheme) => qTheme.theme == theme);
            }),
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
                .map((theme) => DropdownMenuItem(
                    value: theme.difficulty, child: Text(theme.name)))
                .toList(),
            onChanged: (difficulty) {
              quiz.quizDifficulty = quizDifficulty
                  .firstWhere((qDiff) => qDiff.difficulty == difficulty);
            }),
      ],
    );
  }
}

class _BeginButtonWidget extends StatelessWidget {
  _BeginButtonWidget({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Hero(
          tag: 'begin_button',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
                height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text("Let's quiz begin!"))),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              quiz.loadedQuestions = [];
              quiz.compliteQuestionsCount = 0;
              quiz.userScore = 0;

              if (quiz.quizTheme == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.tertiaryContainer,
                  elevation: 20,
                  duration: const Duration(seconds: 2),
                  content: Text(
                    "You need to select quiz theme before",
                    style: TextStyle(color: colorScheme.inverseSurface),
                  ),
                ));
                return;
              }
              if (quiz.quizDifficulty == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.tertiaryContainer,
                  elevation: 20,
                  duration: const Duration(seconds: 1),
                  content: Text(
                    "You need to select quiz difficulty before",
                    style: TextStyle(color: colorScheme.inverseSurface),
                  ),
                ));
                return;
              }

              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => QuizScreenWidget(quiz: quiz),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
            splashColor: colorScheme.tertiaryContainer.withOpacity(.2),
            hoverColor: colorScheme.tertiaryContainer.withOpacity(.2),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              height: 50,
              width: double.maxFinite,
            ),
          ),
        ),
      ],
    );
  }
}
