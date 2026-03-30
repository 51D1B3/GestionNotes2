import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/create_semester_screen.dart';
import 'package:notes_app/widgets/app_drawer.dart';
import 'package:notes_app/widgets/custom_page_route.dart';
import '../services/firestore_service.dart';
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _translateSemesterName(String name) {
    if (name.contains("Semestre")) {
      return name.replaceAll("Semestre", "Semester".tr());
    }
    return name;
  }

  void _showDeleteConfirmation(BuildContext context, String semesterId, String semesterName) {
    final service = FirestoreService();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Delete'.tr()),
          content: Text('${"Are you sure you want to delete".tr()} ${_translateSemesterName(semesterName)} ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'.tr()),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: Text('Delete'.tr()),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                service.deleteSemester(semesterId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Home".tr()),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No semesters found.".tr()),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text("Add".tr()),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => const CreateSemesterScreen(hasExistingSemesters: false)),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final semesters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final semester = semesters[index];
              final semesterData = semester.data() as Map<String, dynamic>;
              final String semesterName = semesterData['name'] ?? '';
              final Timestamp timestamp = semesterData['createdAt'] ?? Timestamp.now();

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(_translateSemesterName(semesterName), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(timestamp.toDate().toLocal().toString().substring(0, 16)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _showDeleteConfirmation(context, semester.id, semesterName),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        builder: (_) => SubjectScreen(
                          semesterId: semester.id,
                          semesterName: semesterName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          service.getSemesters().first.then((snap) {
            final hasSemesters = snap.docs.isNotEmpty;
            Navigator.push(
              context,
              CustomPageRoute(builder: (context) => CreateSemesterScreen(hasExistingSemesters: hasSemesters)),
            );
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
