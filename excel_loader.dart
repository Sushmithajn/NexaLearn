import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AptitudeScreen extends StatefulWidget {
  const AptitudeScreen({super.key});

  @override
  AptitudeQuizState createState() => AptitudeQuizState();
}

class AptitudeQuizState extends State<AptitudeScreen> {
  List<Map<String, dynamic>> _easyQuestions = [];
  List<Map<String, dynamic>> _mediumQuestions = [];
  List<Map<String, dynamic>> _hardQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      developer.log("Loading Excel File...");
      ByteData data = await rootBundle.load("assets/data/aptitude_question.xlsx");
      Uint8List bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> easyQuestions = [];
      List<Map<String, dynamic>> mediumQuestions = [];
      List<Map<String, dynamic>> hardQuestions = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        for (var row in sheet.rows.skip(1)) {
          if (row.length < 8) continue;

          var question = row[0]?.value.toString() ?? "";
          var description = row[1]?.value.toString() ?? "";
          var optionA = row[2]?.value.toString() ?? "";
          var optionB = row[3]?.value.toString() ?? "";
          var optionC = row[4]?.value.toString() ?? "";
          var optionD = row[5]?.value.toString() ?? "";
          var answer = row[6]?.value.toString() ?? "";
          var difficulty = row[7]?.value.toString().toLowerCase() ?? "";

          if (question.isEmpty || answer.isEmpty || difficulty.isEmpty) continue;

          var questionData = {
            "question": question,
            "description": description,
            "options": [optionA, optionB, optionC, optionD],
            "answer": answer
          };

          if (difficulty == "easy") {
            easyQuestions.add(questionData);
          } else if (difficulty == "medium") {
            mediumQuestions.add(questionData);
          } else if (difficulty == "hard") {
            hardQuestions.add(questionData);
          }
        }
      }

      developer.log("Questions Loaded: Easy(${easyQuestions.length}), Medium(${mediumQuestions.length}), Hard(${hardQuestions.length})");

      if (mounted) {
        setState(() {
          _easyQuestions = easyQuestions;
          _mediumQuestions = mediumQuestions;
          _hardQuestions = hardQuestions;
          isLoading = false;
        });
      }
    } catch (e) {
      developer.log("Error loading Excel file: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load Excel file.")),
        );
      }
    }
  }

  void navigateToQuiz(List<Map<String, dynamic>> questions, String difficulty) {
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No $difficulty questions found!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(questions: questions, difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aptitude Quiz")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select a Difficulty Level",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    difficultyButton("Easy", Colors.green, _easyQuestions),
                    difficultyButton("Medium", Colors.orange, _mediumQuestions),
                    difficultyButton("Hard", Colors.red, _hardQuestions),
                  ],
                ),
              ],
            ),
    );
  }

  Widget difficultyButton(String label, Color color, List<Map<String, dynamic>> questions) {
    return GestureDetector(
      onTap: () => navigateToQuiz(questions, label),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Questions: ${questions.length}", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ============ Quiz Screen with Gamification ============

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String difficulty;

  const QuizScreen({super.key, required this.questions, required this.difficulty});

  @override
  // ignore: library_private_types_in_public_api
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int score = 50; // Default score
  int currentQuestionIndex = 0;

  void checkAnswer(String selectedAnswer) {
    String correctAnswer = widget.questions[currentQuestionIndex]["answer"];

    setState(() {
      if (selectedAnswer == correctAnswer) {
        score += 3; // +3 for correct answer
      } else {
        score = (score > 2) ? score - 2 : 0; // -2 for wrong answer (but min 0)
      }

      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showResults();
      }
    });
  }

  void showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Text("Your final score: $score"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var question = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz - ${widget.difficulty} Level")),
      body: Column(
        children: [
          Text("Score: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(question["question"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Column(
            children: question["options"].map<Widget>((opt) {
              return ElevatedButton(
                onPressed: () => checkAnswer(opt),
                child: Text(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}