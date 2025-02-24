import 'package:flutter/material.dart';
import 'python.dart'; // Ensure this file contains a valid PythonScreen
import 'java.dart'; // Ensure this file contains a valid JavaTopicsApp

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Programming & Tech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProgrammingTechScreen(),
    );
  }
}

class ProgrammingTechScreen extends StatelessWidget {
  const ProgrammingTechScreen({super.key});

  void navigateToLanguage(BuildContext context, String language) {
    if (language == "Python") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PythonScreen()),
      );
    } else if (language == "Java") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JavaTopicsApp()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageDetailScreen(language: language),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> programmingLanguages = [
      "Python",
      "Java",
      "C",
      "JavaScript",
      "Dart",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Programming & Tech")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Programming Language:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: programmingLanguages.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () => navigateToLanguage(
                        context, programmingLanguages[index]),
                    child: Text(programmingLanguages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageDetailScreen extends StatelessWidget {
  final String language;
  const LanguageDetailScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to $language Programming!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
