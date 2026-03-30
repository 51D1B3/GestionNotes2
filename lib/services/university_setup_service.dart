
import 'package:cloud_firestore/cloud_firestore.dart';

class UniversitySetupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initializeFaculties() async {
    final faculties = {
      "Faculté des Sciences et Techniques (FST)": [
        "Mathématiques",
        "Physique",
        "Chimie",
        "Biologie"
      ],
      "Faculté des Lettres et Sciences Humaines (FLSH)": [
        "Lettres Modernes",
        "Sociologie",
        "Langue Anglaise",
        "Langue Arabe",
        "Histoire"
      ],
      "Faculté des Sciences Administratives et de Gestion (FSAG)": [
        "Gestion",
        "Economie",
        "Administration Publique"
      ]
    };

    final collection = _db.collection('faculties');
    final snapshot = await collection.limit(1).get();

    // Si la collection est vide, on la peuple
    if (snapshot.docs.isEmpty) {
      for (var entry in faculties.entries) {
        await collection.add({
          'name': entry.key,
          'departments': entry.value,
        });
      }
    }
  }
}
