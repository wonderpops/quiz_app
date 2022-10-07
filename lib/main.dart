import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/blocs/quiz_bloc/quiz_bloc.dart';
import 'package:quiz_app/screens/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BlocProvider(
    create: (context) => QuizBloc(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final heroController = HeroController();
    return MaterialApp(
      title: 'Quiz app!',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 54, 254, 205),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 54, 254, 205),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreenWidget(),
    );
  }
}
