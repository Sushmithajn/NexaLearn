import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

typedef JavaTopic = Map<String, String>;

void main() {
  runApp(const JavaTopicsApp());
}

class JavaTopicsApp extends StatelessWidget {
  const JavaTopicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Java Topics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const JavaTopicsScreen(),
    );
  }
}

class JavaTopicsScreen extends StatefulWidget {
  const JavaTopicsScreen({super.key});

  @override
  JavaTopicsScreenState createState() => JavaTopicsScreenState();
}

class JavaTopicsScreenState extends State<JavaTopicsScreen> {
  late Future<List<JavaTopic>> javaTopicsFuture;

  @override
  void initState() {
    super.initState();
    javaTopicsFuture = loadExcelData();
  }

  Future<List<JavaTopic>> loadExcelData() async {
    try {
      ByteData data = await rootBundle.load("assets/java_topics (1).xlsx"); // Ensure this file exists
      Uint8List bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      List<JavaTopic> topics = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        for (var row in sheet.rows.skip(1)) {
          if (row.length < 4) continue; // Ensure row has at least 4 columns

          var title = row[0]?.value?.toString() ?? "No Title";
          var explanation = row[1]?.value?.toString() ?? "No Explanation";
          var example = row[2]?.value?.toString() ?? "No Example";
          var assignment = row[3]?.value?.toString() ?? "No Assignment";

          topics.add({
            'title': title,
            'explanation': explanation,
            'example': example,
            'assignment': assignment,
          });
        }
      }

      if (topics.isEmpty) {
        debugPrint("No topics found in Excel file.");
      }

      return topics;
    } catch (e) {
      debugPrint("Error loading Excel file: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Java Topics')),
      body: FutureBuilder<List<JavaTopic>>(
        future: javaTopicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("Failed to load topics or file is empty"));
          }

          List<JavaTopic> javaTopics = snapshot.data!;
          return ListView.builder(
            itemCount: javaTopics.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text(javaTopics[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection("Explanation", javaTopics[index]['explanation']!),
                          _buildSection("Example", javaTopics[index]['example']!, italic: true),
                          _buildSection("Assignment", javaTopics[index]['assignment']!, bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool bold = false, bool italic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
