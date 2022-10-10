import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/models/question_model.dart';

import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/screens/home_screen/home_screen.dart';

import '../../blocs/quiz_bloc/quiz_bloc.dart';

class ResultsScreenWidget extends StatelessWidget {
  const ResultsScreenWidget({super.key});

  Widget quizLoadedResult(
      date, correctAnswersCount, incorrectAnswersCount, score) {
    // print('$date, $correctAnswersCount, $incorrectAnswersCount, $score');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(DateFormat('yyyy:MM:dd kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(
                date.millisecondsSinceEpoch))
            .toString()),
        Text(correctAnswersCount.toString()),
        Text(incorrectAnswersCount.toString()),
        Text(score.toString())
      ],
    );
  }

  List<TableRow> getTableRowQuizResults(context, List docs) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    List<TableRow> quizResults = [
      TableRow(
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
          ),
          children: const [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.bottom,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Date', textAlign: TextAlign.center),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.bottom,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Correct', textAlign: TextAlign.center),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.bottom,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Incorrect', textAlign: TextAlign.center),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.bottom,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Score', textAlign: TextAlign.center),
              ),
            ),
          ])
    ];
    for (var i = 0; i < docs.length; i++) {
      quizResults.add(TableRow(
          decoration: BoxDecoration(
              color: i % 2 == 0
                  ? colorScheme.tertiaryContainer.withOpacity(.2)
                  : colorScheme.tertiaryContainer.withOpacity(.5)),
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  DateFormat('yyyy.MM.dd\nkk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(
                          docs[i]['date'].millisecondsSinceEpoch))
                      .toString(),
                  minFontSize: 10,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  docs[i]['correct_answers_count'].toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    docs[i]['incorrect_answers_count'].toString(),
                    textAlign: TextAlign.center,
                  ),
                )),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    docs[i]['score'].toString(),
                    textAlign: TextAlign.center,
                  ),
                )),
          ]));
    }
    return quizResults;
  }

  @override
  Widget build(BuildContext context) {
    QuizBloc qBloc = BlocProvider.of<QuizBloc>(context);
    QuizEndedState qBlocState = qBloc.state as QuizEndedState;
    final Stream<QuerySnapshot> results = FirebaseFirestore.instance
        .collection('quiz_results')
        .orderBy('score', descending: true)
        .where('quiz_theme', isEqualTo: qBlocState.qTheme.name)
        .where('quiz_difficulty', isEqualTo: qBlocState.qDifficulty.name)
        .limit(100)
        .snapshots();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
        child: Scaffold(
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'You answered right on ${(qBlocState.userScore / 100).round()}/${qBlocState.questions.length} questions!',
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            Text(
              'Your score: ${qBlocState.userScore}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                  stream: results,
                  builder: (
                    BuildContext context,
                    snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return const Text(
                          'Error in loading results from firestore');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final data = snapshot.requireData;
                    List<TableRow> results =
                        getTableRowQuizResults(context, data.docs);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                colorScheme.tertiaryContainer.withOpacity(.2)),
                        child: ListView(
                          children: [
                            Container(
                              height: 50,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: colorScheme.tertiaryContainer),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: AutoSizeText(
                                    'Rating for ${qBlocState.qTheme.name} ${qBlocState.qDifficulty.name}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    minFontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            results.length > 1
                                ? Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1),
                                      2: FlexColumnWidth(1),
                                      3: FlexColumnWidth(1),
                                      4: FlexColumnWidth(1)
                                    },
                                    children: getTableRowQuizResults(
                                        context, data.docs),
                                  )
                                : const Center(
                                    child: Text('Results not found'),
                                  ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(height: 16),
            _UploadResultsButtonWidget(),
            const SizedBox(height: 16),
            const _ReturnToMenuButton(),
          ],
        ),
      ),
    ));
  }
}

class _ReturnToMenuButton extends StatefulWidget {
  const _ReturnToMenuButton({super.key});

  @override
  State<_ReturnToMenuButton> createState() => _ReturnToMenuButtonState();
}

class _ReturnToMenuButtonState extends State<_ReturnToMenuButton> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Hero(
          tag: 'loading_questions',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
                height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(.2),
                  border: Border.all(color: colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text("Return to menu"))),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomeScreenWidget(),
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

class _UploadResultsButtonWidget extends StatefulWidget {
  _UploadResultsButtonWidget({super.key});
  bool isLoading = false;
  bool wasUploaded = false;

  @override
  State<_UploadResultsButtonWidget> createState() =>
      _UploadResultsButtonWidgetState();
}

class _UploadResultsButtonWidgetState
    extends State<_UploadResultsButtonWidget> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    QuizBloc qBloc = BlocProvider.of<QuizBloc>(context);
    QuizEndedState qBlocState = qBloc.state as QuizEndedState;
    return Visibility(
      visible: !widget.wasUploaded,
      child: Stack(
        children: [
          Material(
            type: MaterialType.transparency,
            child: Container(
                height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                    child: widget.isLoading
                        ? const CircularProgressIndicator()
                        : widget.wasUploaded
                            ? const Text("Go to start")
                            : const Text("Upload results"))),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                widget.isLoading = true;
                setState(() {});

                try {
                  CollectionReference results =
                      FirebaseFirestore.instance.collection('quiz_results');

                  results.add({
                    'date': Timestamp.fromDate(DateTime.now()),
                    'quiz_theme': qBlocState.qTheme.name,
                    'quiz_difficulty': qBlocState.qDifficulty.name,
                    'correct_answers_count':
                        (qBlocState.userScore / 100).round(),
                    'incorrect_answers_count': qBlocState.questions.length -
                        (qBlocState.userScore / 100).round(),
                    'score': qBlocState.userScore,
                  });

                  widget.isLoading = false;
                  widget.wasUploaded = true;

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.tertiaryContainer,
                    elevation: 20,
                    duration: const Duration(seconds: 2),
                    content: Text(
                      "Your score was uploaded",
                      style: TextStyle(color: colorScheme.inverseSurface),
                    ),
                  ));
                } catch (e) {
                  widget.wasUploaded = false;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colorScheme.tertiaryContainer,
                    elevation: 20,
                    duration: const Duration(seconds: 2),
                    content: Text(
                      "Error when uploading score :c",
                      style: TextStyle(color: colorScheme.inverseSurface),
                    ),
                  ));
                }

                setState(() {});
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
      ),
    );
  }
}
