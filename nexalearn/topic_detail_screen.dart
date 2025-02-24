import 'package:flutter/material.dart';

class TopicDetailScreen extends StatelessWidget {
  final Map<String, String> topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic["title"]!)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic["description"]!, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Assignment:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(topic["assignment"]!, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

