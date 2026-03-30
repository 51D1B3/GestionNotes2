import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/history_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import 'package:open_file/open_file.dart';

class SubjectScreen extends StatelessWidget {
  final String semesterId;
  final String semesterName;

  const SubjectScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  int _getMentionValue(String mention) {
    switch (mention) {
      case "Très bien": return 4;
      case "Bien": return 3;
      case "Assez bien": return 2;
      case "Passable": return 1;
      default: return 0;
    }
  }

  String _getMention(double moyenne) {
    if (moyenne < 5) return "Echec";
    if (moyenne <= 5.99) return "Passable";
    if (moyenne <= 6.99) return "Assez bien";
    if (moyenne <= 7.99) return "Bien";
    return "Très bien";
  }

  void _showDeleteConfirmation(BuildContext context, String subjectId) {
    final service = FirestoreService();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette matière ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Oui'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                service.deleteSubject(semesterId, subjectId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAutoNoteDialog(BuildContext context, {DocumentSnapshot? subject}) {
    final service = FirestoreService();
    final nameController = TextEditingController(text: subject?['name']);
    final neController = TextEditingController(text: subject != null ? subject['ne'].toString() : '');
    final ndgController = TextEditingController(text: subject != null ? subject['ndg'].toString() : '');
    final nefController = TextEditingController(text: subject != null ? subject['nef'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subject == null ? 'Ajouter une matière de 3 notes' : 'Modifier la matière', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom de la matière')),
                TextField(controller: neController, decoration: const InputDecoration(labelText: 'Note Examen'), keyboardType: TextInputType.number),
                TextField(controller: ndgController, decoration: const InputDecoration(labelText: 'Devoir de Groupe'), keyboardType: TextInputType.number),
                TextField(controller: nefController, decoration: const InputDecoration(labelText: 'Examen Final'), keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(child: const Text('Annuler'), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text('Valider'),
                      onPressed: () {
                        final name = nameController.text;
                        final ne = double.tryParse(neController.text) ?? 0.0;
                        final ndg = double.tryParse(ndgController.text) ?? 0.0;
                        final nef = double.tryParse(nefController.text) ?? 0.0;

                        if (name.isNotEmpty) {
                          final moyenneMatiere = ne * 0.35 + ndg * 0.25 + nef * 0.40;
                          final mention = _getMention(moyenneMatiere);

                          if (subject == null) {
                            service.addSubjectWithNotes(semesterId, name, ne, ndg, nef, moyenneMatiere, mention);
                          } else {
                            service.updateSubjectWithNotes(semesterId, subject.id, name, ne, ndg, nef, moyenneMatiere, mention);
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManualNoteDialog(BuildContext context, {DocumentSnapshot? subject}) {
    final service = FirestoreService();
    final nameController = TextEditingController(text: subject?['name']);
    final neController = TextEditingController(text: subject != null ? subject['ne'].toString() : '');
    final nefController = TextEditingController(text: subject != null ? subject['nef'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ajouter une matière de 2 notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom de la matière')),
                TextField(controller: neController, decoration: const InputDecoration(labelText: 'Note Examen'), keyboardType: TextInputType.number),
                TextField(controller: nefController, decoration: const InputDecoration(labelText: 'Examen Final'), keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(child: const Text('Annuler'), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text('Valider'),
                      onPressed: () {
                        final name = nameController.text;
                        final ne = double.tryParse(neController.text) ?? 0.0;
                        final nef = double.tryParse(nefController.text) ?? 0.0;

                        if (name.isNotEmpty) {
                          final moyenneMatiere = (ne * 0.4) + (nef * 0.6);
                          final mention = _getMention(moyenneMatiere);

                          if (subject == null) {
                            service.addSubjectManual(semesterId, name, ne, nef, moyenneMatiere, mention);
                          } else {
                            service.updateSubjectManual(semesterId, subject.id, name, ne, nef, moyenneMatiere, mention);
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.calculate_outlined, color: Color(0xFF00A8E8), size: 24),
              title: const Text('Ajouter une matière de 3 notes (6 crédits)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showAutoNoteDialog(context);
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.edit_note, color: Color(0xFF00A8E8), size: 24),
              title: const Text('Ajouter une matière de 2 notes (3 crédits)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showManualNoteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final pdfService = PdfService();
    final historyService = HistoryService();

    return Scaffold(
      appBar: AppBar(
        title: Text(semesterName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
                final subjectsSnapshot = await service.getSubjects(semesterId).first;
                double totalWeightedIndices = 0;
                int totalCredits = 0;

                final subjects = subjectsSnapshot.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isManual = data['isManual'] ?? false;
                    double moyenne = data['moyenneMatiere'] ?? 0.0;
                    String mention = data['mention'] ?? _getMention(moyenne);

                    int indice = _getMentionValue(mention);
                    int credit = isManual ? 3 : 6;
                    totalWeightedIndices += (indice * credit);
                    totalCredits += credit;

                    return {
                        'name': data['name'], 'ne': data['ne'], 'ndg': data['ndg'],
                        'nef': data['nef'], 'moyenneMatiere': moyenne, 'mention': mention,
                    };
                }).toList();

                final semesterDoc = await service.getSemesterDoc(semesterId);
                if (!semesterDoc.exists) return;
                final semesterDetails = semesterDoc.data() as Map<String, dynamic>;
                
                final average = (totalCredits > 0) ? (totalWeightedIndices / totalCredits) : 0.0;

                final filePath = await pdfService.generateSemesterPdf(
                    semesterName, subjects, average,
                    semesterDetails['faculty'], semesterDetails['department'], semesterDetails['level']
                );

                await historyService.addToHistory(filePath);
                OpenFile.open(filePath);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSubjects(semesterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune matière. Appuyez sur + pour en ajouter une."));
          }

          final subjects = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.8)),
              columns: const [
                DataColumn(label: Text('Matière', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes E', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes G', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes F', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Moyenne', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Mention', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ],
              rows: subjects.map((subject) {
                final data = subject.data() as Map<String, dynamic>;
                bool isManual = data['isManual'] ?? false;

                return DataRow(
                   color: MaterialStateProperty.resolveWith<Color?>((states) {
                        final index = subjects.indexOf(subject);
                        return index.isEven ? Colors.grey.withOpacity(0.1) : null;
                   }),
                  cells: [
                    DataCell(Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(data['ne']?.toStringAsFixed(2) ?? '-')),
                    DataCell(Text(isManual ? '-' : (data['ndg']?.toStringAsFixed(2) ?? '-'))),
                    DataCell(Text(data['nef']?.toStringAsFixed(2) ?? '-')),
                    DataCell(Text(data['moyenneMatiere']?.toStringAsFixed(2) ?? '0.0')),
                    DataCell(Text(data['mention'] ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => isManual ? _showManualNoteDialog(context, subject: subject) : _showAutoNoteDialog(context, subject: subject)
                        ),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, subject.id)),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00A8E8).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddOptionsMenu(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
