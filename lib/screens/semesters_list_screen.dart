import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/firestore_service.dart';

class SemestersListScreen extends StatelessWidget {
  const SemestersListScreen({super.key});

  int _getMentionValue(String mention) {
    switch (mention) {
      case "Très bien": return 4;
      case "Bien": return 3;
      case "Assez bien": return 2;
      case "Passable": return 1;
      default: return 0;
    }
  }

 String _getOverallMention(double average) {
    if (average < 1) return "Echec";
    if (average < 2) return "Passable";
    if (average < 3) return "Assez bien";
    if (average < 4) return "Bien";
    return "Très bien";
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF051923) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Moyennes des Semestres'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3CDEED)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun semestre à afficher."));
          }

          final semesters = snapshot.data!.docs;

          return ListView.builder(
            itemCount: semesters.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              final semester = semesters[index];
              final semesterData = semester.data() as Map<String, dynamic>;

              return FutureBuilder<QuerySnapshot>(
                future: service.getSubjects(semester.id).first,
                builder: (context, subjectSnapshot) {
                  if (!subjectSnapshot.hasData) return const SizedBox.shrink();

                  double totalWeightedIndices = 0;
                  int totalCredits = 0;
                  final subjects = subjectSnapshot.data!.docs;
                  
                  for (var doc in subjects) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isManual = data['isManual'] ?? false;
                    String mention = data['mention'] ?? 'Echec';
                    int indice = _getMentionValue(mention);
                    int credit = isManual ? 3 : 6;
                    totalWeightedIndices += (indice * credit);
                    totalCredits += credit;
                  }
                  
                  double average = (totalCredits > 0) ? (totalWeightedIndices / totalCredits) : 0.0;
                  String overallMention = _getOverallMention(average);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      title: Text(
                        semesterData['name'], 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, // Empêche le titre de pousser le badge
                      ),
                      trailing: Container(
                        constraints: const BoxConstraints(maxWidth: 180), // Limite la largeur du badge
                        child: Chip(
                          label: Text(
                            '${average.toStringAsFixed(2)} - $overallMention',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: isDarkMode ? const Color(0xFF0A2E36) : Colors.blue.shade100,
                          side: isDarkMode ? const BorderSide(color: Color(0xFF3CDEED), width: 0.5) : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
