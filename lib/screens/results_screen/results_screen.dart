import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/models/question_model.dart';

import 'package:quiz_app/models/quiz_model.dart';
import 'package:quiz_app/screens/home_screen/home_screen.dart';

class ResultsScreenWidget extends StatelessWidget {
  ResultsScreenWidget({super.key, required this.quiz});
  Quiz quiz;

  int getUserRightAnswersCount() {
    int count = 0;
    for (Question q in quiz.loadedQuestions) {
      if (q.userCorrectAnswersCount == q.correctAnswersCount) {
        count += 1;
      }
    }
    return count;
  }

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

  List<TableRow> getTableRowQuizResults(docs) {
    List<TableRow> quizResults = [
      const TableRow(children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: SizedBox(
            height: 50,
            child: Text('Date', textAlign: TextAlign.center),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Text('Correct', textAlign: TextAlign.center),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Text('Incorrect', textAlign: TextAlign.center),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Text('Score', textAlign: TextAlign.center),
        ),
      ])
    ];
    for (var d in docs) {
      quizResults.add(TableRow(children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: SizedBox(
            height: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('yyyy.MM.dd\nkk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                        d['date'].millisecondsSinceEpoch))
                    .toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            d['correct_answers_count'].toString(),
            textAlign: TextAlign.center,
          ),
        ),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              d['incorrect_answers_count'].toString(),
              textAlign: TextAlign.center,
            )),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              d['score'].toString(),
              textAlign: TextAlign.center,
            )),
      ]));
    }
    return quizResults;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> results = FirebaseFirestore.instance
        .collection('quiz_results')
        .orderBy('score', descending: true)
        .where('quiz_theme', isEqualTo: quiz.quizTheme!.name)
        .where('quiz_difficulty', isEqualTo: quiz.quizDifficulty!.name)
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
              'You answered right on ${getUserRightAnswersCount()}/${quiz.loadedQuestions.length} questions!',
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            Text(
              'Your score: ${quiz.userScore}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            StreamBuilder<QuerySnapshot>(
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
                  List<TableRow> results = getTableRowQuizResults(data.docs);

                  return Container(
                    height: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: colorScheme.tertiaryContainer)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: colorScheme.tertiaryContainer),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Rating for ${quiz.quizTheme!.name} ${quiz.quizDifficulty!.name}:',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                              child: results.length > 1
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SingleChildScrollView(
                                        child: Table(
                                          border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  color: colorScheme
                                                      .tertiaryContainer)),
                                          columnWidths: const {
                                            0: FlexColumnWidth(1),
                                            2: FlexColumnWidth(1),
                                            3: FlexColumnWidth(1),
                                            4: FlexColumnWidth(1)
                                          },
                                          children:
                                              getTableRowQuizResults(data.docs),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Text('Results not found'),
                                    )),
                        ],
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 32),
            _UploadResultsButtonWidget(quiz: quiz)
          ],
        ),
      ),
    ));
  }
}

class _UploadResultsButtonWidget extends StatefulWidget {
  _UploadResultsButtonWidget({super.key, required this.quiz});
  final Quiz quiz;
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
                child: Center(
                    child: widget.isLoading
                        ? const CircularProgressIndicator()
                        : widget.wasUploaded
                            ? const Text("Go to start")
                            : const Text("Upload results"))),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (widget.wasUploaded) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomeScreenWidget(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                );
                return;
              }

              widget.isLoading = true;
              setState(() {});

              CollectionReference results =
                  FirebaseFirestore.instance.collection('quiz_results');

              int cAnswersCount = 0;
              for (Question q in widget.quiz.loadedQuestions) {
                if (q.userCorrectAnswersCount == q.correctAnswersCount) {
                  cAnswersCount += 1;
                }
              }
              results.add({
                'date': Timestamp.fromDate(DateTime.now()),
                'quiz_theme': widget.quiz.quizTheme!.name,
                'quiz_difficulty': widget.quiz.quizDifficulty!.name,
                'correct_answers_count': cAnswersCount,
                'incorrect_answers_count':
                    widget.quiz.loadedQuestions.length - cAnswersCount,
                'score': widget.quiz.userScore,
              });

              widget.isLoading = false;
              widget.wasUploaded = true;
              setState(() {});

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
