import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class PythonScreen extends StatefulWidget {
  const PythonScreen({super.key});

  @override
  PythonScreenState createState() => PythonScreenState();
}

class PythonScreenState extends State<PythonScreen> {
  List<Map<String, String>> topics = [];

  @override
  void initState() {
    super.initState();
    loadExcelData();
  }

  Future<void> loadExcelData() async {
    try {
      ByteData data = await rootBundle.load("assets/python_detailed_tutorial.xlsx");
      Uint8List bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, String>> loadedTopics = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) { // Skipping header row
          if (row.length >= 4) { // Ensure the row has enough columns
            loadedTopics.add({
              "title": row[0]?.value.toString() ?? "No Title",
              "explanation": row[1]?.value.toString() ?? "No Explanation",
              "example": row[2]?.value.toString() ?? "No Example",
              "question": row[3]?.value.toString() ?? "No Question",
            });
          }
        }
      }

      setState(() {
        topics = loadedTopics;
      });

      debugPrint("Excel Data Loaded Successfully: ${topics.length} topics");
    } catch (e) {
      debugPrint("Error loading Excel file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Python Topics")),
      body: topics.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(topics[index]["title"]!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicDetailScreen(topic: topics[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final Map<String, String> topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic["title"]!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic["title"]!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Explanation:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(topic["explanation"]!, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),
              Text(
                "Example Code:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topic["example"]!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Assignment Question:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(topic["question"]!, style: const TextStyle(fontSize: 16)),

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
      ),
    );
  }
}
