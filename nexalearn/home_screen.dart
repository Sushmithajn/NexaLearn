import 'package:flutter/material.dart';
import 'dart:async';
import 'study_plan_screen.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';
import 'prgskl.dart';
import 'aptitude_screen.dart';

void main() {
  runApp(const NexaLearnApp());
}

class NexaLearnApp extends StatelessWidget {
  const NexaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaLearn',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Show Splash Screen First
    );
  }
}

/// **Splash Screen that shows the logo first**
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Image.asset(
          "assets/icon.png", // Ensure the image is in assets
          height: 120,
        ),
      ),
    );
  }
}

/// **Home Screen**
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 15),
            _buildGridMenu(context),
          ],
        ),
      ),
    );
  }

  /// **Top banner with logo & text**
  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "NexaLearn",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  "Study Better, Achieve More!",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/icon.png", // Ensure this image exists
              height: 60,
            ),
          ),
        ],
      ),
    );
  }

  /// **Grid-based menu for different features**
  Widget _buildGridMenu(BuildContext context) {
    final menuItems = [
      {"title": "Study Alarm", "color": const Color.fromARGB(255, 85, 125, 158), "icon": Icons.language, "page": const StudyPlanScreen()},
      {"title": "Quiz", "color": const Color.fromARGB(255, 255, 158, 13), "icon": Icons.calculate, "page": QuizScreen()},
      {"title": "Programming & Tech", "color": const Color.fromARGB(255, 118, 64, 128), "icon": Icons.network_ping, "page": const ProgrammingTechScreen()},
      {"title": "Aptitude", "color": const Color.fromARGB(255, 51, 133, 54), "icon": Icons.engineering_sharp, "page": const AptitudeChallengeScreen()},
      {"title": "Interview Skills", "color": const Color.fromARGB(255, 0, 116, 104), "icon": Icons.menu_book, "page": QuizScreen()},
      {"title": "Other Courses", "color": const Color.fromARGB(255, 182, 98, 92), "icon": Icons.search, "page": const ProgressScreen()},
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;
    double childAspectRatio = screenWidth < 400 ? 1.0 : 1.5;

    return Flexible(
      fit: FlexFit.loose, // Prevents overflow on small screens
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuButton(
              context,
              item["title"] as String,
              item["color"] as Color,
              item["icon"] as IconData,
              item["page"] as Widget,
            );
          },
        ),
      ),
    );
  }

  /// **Menu button widget**
  Widget _buildMenuButton(BuildContext context, String text, Color color, IconData icon, Widget page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: constraints.maxWidth * 0.9, // Adjust width dynamically
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha((0.5 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 35, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
