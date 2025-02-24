import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuizScreen(),
    );
  }
}

class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String hint;

  Quiz({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hint,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int coins = 50;
  bool hintUsed = false;
  List<Quiz> quizzes = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestionsFromExcel();
  }

  Future<void> loadQuestionsFromExcel() async {
    try {
      final ByteData data = await rootBundle.load('assets/questions.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      final Excel excel = Excel.decodeBytes(bytes);
      List<Quiz> loadedQuizzes = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          loadedQuizzes.add(Quiz(
            question: row[0]?.value.toString() ?? '',
            options: [
              row[1]?.value.toString() ?? '',
              row[2]?.value.toString() ?? '',
              row[3]?.value.toString() ?? '',
              row[4]?.value.toString() ?? '',
            ],
            correctAnswer: row[5]?.value.toString() ?? '',
            explanation: row[6]?.value.toString() ?? '',
            hint: row[7]?.value.toString() ?? '',
          ));
        }
      }

      setState(() {
        quizzes = loadedQuizzes;
        quizzes.shuffle(Random());
      });
    } catch (e) {
      showSnackBar("Error loading questions: $e");
    }
  }

  void checkAnswer(String selectedOption) {
    setState(() {
      if (selectedOption == quizzes[currentQuestionIndex].correctAnswer) {
        coins += hintUsed ? 1 : 3;
        showResult("Correct!", quizzes[currentQuestionIndex].explanation, Colors.green);
      } else {
        showSnackBar("Wrong answer! Try again.");
      }
      hintUsed = false;
    });
  }

  void nextQuestion() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (currentQuestionIndex < quizzes.length - 1) {
          currentQuestionIndex++;
        } else {
          showResult("Quiz Completed!", "You've answered all questions!", Colors.blue);
        }
      });
    });
  }

  void useHint() {
    if (coins >= 2) {
      setState(() {
        coins -= 2;
        hintUsed = true;
      });
      showHint();
    } else {
      showSnackBar("Not enough coins for a hint!");
    }
  }

  void showResult(String title, String message, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nextQuestion();
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }

  void showHint() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hint"),
          content: Text(quizzes[currentQuestionIndex].hint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }
 
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Programming & Aptitude Quiz"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 5),
                Text("$coins Coins", style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Level ${currentQuestionIndex + 1}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            Text(quizzes[currentQuestionIndex].question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...quizzes[currentQuestionIndex].options.map((option) => ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  child: Text(option),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: useHint,
              child: const Text("Use Hint (-2 Coins)"),
            ),
          ],
        ),
      ),
    );
  }
}
