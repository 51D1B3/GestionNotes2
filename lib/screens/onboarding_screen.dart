import 'package:flutter/material.dart';
import 'package:notes_app/main.dart'; // Import pour accéder à AuthWrapper
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      // Rediriger vers AuthWrapper pour garantir que l'authentification se lance
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper(key: ValueKey('AuthWrapper'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: const [
              OnboardingPage(
                imagePath: 'assets/applogo.png',
                title: "Bienvenue sur UniNotes",
                description: "Votre partenaire pour une gestion simple et efficace de vos notes universitaires.",
              ),
              OnboardingPage(
                imagePath: 'assets/applogo.png',
                title: "Suivez votre progression",
                description: "Visualisez vos moyennes et vos statistiques semestre par semestre pour ne jamais perdre le fil.",
              ),
              OnboardingPage(
                imagePath: 'assets/applogo.png',
                title: "Exportez vos relevés",
                description: "Générez des relevés de notes professionnels en PDF en un seul clic.",
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(3, (index) => buildDot(index, context)),
                ),
                if (_currentPage == 2)
                  ElevatedButton(
                    onPressed: _completeOnboarding,
                    child: const Text("Commencer"),
                  )
                else
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: const Text("Suivant"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPage(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 280),
          const SizedBox(height: 40),
          Text(title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
