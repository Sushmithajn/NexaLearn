import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AptitudeChallengeScreen extends StatefulWidget {
  const AptitudeChallengeScreen({super.key});

  @override
  AptitudeChallengeState createState() => AptitudeChallengeState();
}

class AptitudeChallengeState extends State<AptitudeChallengeScreen> {
  List<Map<String, dynamic>> _basicQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBasicQuestions();
  }

  Future<void> loadBasicQuestions() async {
    try {
      developer.log("Loading Excel File...");
      ByteData data = await rootBundle.load("assets/basic_aptitude_questions (1).xlsx");
      Uint8List bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> basicQuestions = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        for (var row in sheet.rows.skip(1)) {
          if (row.length < 6) continue; // Ensure enough columns exist

          String? question = row[0]?.value?.toString();
          String? optionA = row[1]?.value?.toString();
          String? optionB = row[2]?.value?.toString();
          String? optionC = row[3]?.value?.toString();
          String? optionD = row[4]?.value?.toString();
          String? correctAnswer = row[5]?.value?.toString();
          String? explanation = row.length > 6 ? row[6]?.value?.toString() : "";

          if (question == null || question.isEmpty) continue;

          basicQuestions.add({
            "question": question,
            "options": [optionA, optionB, optionC, optionD].whereType<String>().toList(),
            "correctAnswer": correctAnswer ?? "",
            "explanation": explanation ?? "",
          });
        }
      }

      developer.log("Basic Questions Loaded: ${basicQuestions.length}");

      if (mounted) {
        setState(() {
          _basicQuestions = basicQuestions;
          isLoading = false;
        });
      }
    } catch (e) {
      developer.log("Error loading Excel file: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void startBasicChallenge() {
    if (_basicQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Basic questions found!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeScreen(questions: _basicQuestions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aptitude Challenge")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: GestureDetector(
                onTap: startBasicChallenge,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Basic", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Start Quiz", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class ChallengeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const ChallengeScreen({super.key, required this.questions});

  @override
  ChallengeScreenState createState() => ChallengeScreenState();
}

class ChallengeScreenState extends State<ChallengeScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;

  void checkAnswer(String option) {
    if (_isAnswered) return; // Prevent multiple selections

    bool correct = option == widget.questions[_currentIndex]["correctAnswer"];
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      _isCorrect = correct;
    });

    Future.delayed(const Duration(seconds: 2), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
        _isCorrect = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quiz Completed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Question ${_currentIndex + 1}")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question["question"],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Display Options with feedback
            ...question["options"].map<Widget>((opt) {
              bool isCorrectOption = opt == question["correctAnswer"];
              bool isSelected = opt == _selectedOption;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(opt),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (isSelected) {
                          return isCorrectOption ? Colors.green : Colors.red;
                        }
                        return Colors.blue;
                      },
                    ),
                  ),
                  child: Text(opt),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            // Show feedback message
            if (_isAnswered)
              Text(
                _isCorrect ? "Correct Answer! 🎉" : "Wrong Answer! ❌",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
              ),

            // Show Explanation after answering
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Explanation: ${question["explanation"]}",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
