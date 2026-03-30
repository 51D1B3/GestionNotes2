import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/firestore_service.dart';

class FacultiesScreen extends StatelessWidget {
  const FacultiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facultés et Départements'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getFaculties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune faculté n'a été trouvée."));
          }

          final faculties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faculties.length,
            itemBuilder: (context, index) {
              final faculty = faculties[index];
              final facultyData = faculty.data() as Map<String, dynamic>;
              final List<dynamic> departments = facultyData['departments'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(facultyData['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: departments.map((dept) {
                    return ListTile(
                      title: Text(dept.toString()),
                      contentPadding: const EdgeInsets.only(left: 30.0),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
