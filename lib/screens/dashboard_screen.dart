import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final service = FirestoreService();

  double moyenneGenerale = 0;
  double meilleure = 0;
  double pire = 20;
  int totalSemestres = 0;
  int totalMatieres = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    var stats = await service.getGlobalStats();

    setState(() {
      moyenneGenerale = stats["moyenneGenerale"];
      meilleure = stats["meilleure"];
      pire = stats["pire"];
      totalSemestres = stats["totalSemestres"];
      totalMatieres = stats["totalMatieres"];
    });
  }

  Widget statCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de Bord")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            statCard("Moyenne Générale",
                moyenneGenerale.toStringAsFixed(2)),
            statCard("Semestres", totalSemestres.toString()),
            statCard("Matières", totalMatieres.toString()),
            statCard("Meilleure Moyenne",
                meilleure.toStringAsFixed(2)),
            statCard("Plus Faible Moyenne",
                pire.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }
}