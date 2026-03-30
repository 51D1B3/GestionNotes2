import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/pdf_service.dart';

class CreateSemesterFlow extends StatefulWidget {
  @override
  _CreateSemesterFlowState createState() =>
      _CreateSemesterFlowState();
}

class _CreateSemesterFlowState
    extends State<CreateSemesterFlow> {

  int _currentStep = 0;

  List<String> faculties = [];
  List<String> departments = [];
  List<String> levels = ["L1", "L2", "L3"];

  String? selectedFaculty;
  String? selectedDepartment;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  /// 🔹 Charger les facultés depuis Firestore
  void loadFaculties() async {
    var snapshot =
        await FirebaseFirestore.instance.collection("faculties").get();

    setState(() {
      faculties =
          snapshot.docs.map((doc) => doc["name"] as String).toList();
    });
  }

  /// 🔹 Passer à l'étape suivante automatiquement
  void nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer un semestre"),
      ),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          return SizedBox(); // on enlève les boutons suivant/précédent
        },
        steps: [

          /// 🔹 ETAPE 1 - Faculté
          Step(
            title: Text("Choisir la Faculté"),
            isActive: _currentStep >= 0,
            content: DropdownButtonFormField<String>(
              value: selectedFaculty,
              decoration: InputDecoration(
                labelText: "Faculté",
                border: OutlineInputBorder(),
              ),
              items: faculties
                  .map((faculty) => DropdownMenuItem(
                        value: faculty,
                        child: Text(faculty),
                      ))
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  selectedFaculty = value;
                  selectedDepartment = null;
                  departments.clear();
                });

                // 🔥 Charger les départements selon la faculté
                var query = await FirebaseFirestore.instance
                    .collection("faculties")
                    .where("name", isEqualTo: value)
                    .get();

                if (query.docs.isNotEmpty) {
                  setState(() {
                    departments = List<String>.from(
                        query.docs.first["departments"]);
                  });
                }

                nextStep();
              },
            ),
          ),

          /// 🔹 ETAPE 2 - Département
          Step(
            title: Text("Choisir le Département"),
            isActive: _currentStep >= 1,
            content: DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: InputDecoration(
                labelText: "Département",
                border: OutlineInputBorder(),
              ),
              items: departments
                  .map((dep) => DropdownMenuItem(
                        value: dep,
                        child: Text(dep),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
                nextStep();
              },
            ),
          ),

          /// 🔹 ETAPE 3 - Niveau
          Step(
            title: Text("Choisir le Niveau"),
            isActive: _currentStep >= 2,
            content: DropdownButtonFormField<String>(
              value: selectedLevel,
              decoration: InputDecoration(
                labelText: "Licence",
                border: OutlineInputBorder(),
              ),
              items: levels
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLevel = value;
                });
                nextStep();
              },
            ),
          ),

          /// 🔹 ETAPE 4 - Résumé + PDF
          Step(
            title: Text("Résumé & PDF"),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Faculté : $selectedFaculty"),
                Text("Département : $selectedDepartment"),
                Text("Niveau : $selectedLevel"),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {

                    List<Map<String, dynamic>> subjects = [
                      {
                        "name": "Programmation",
                        "coefficient": 3,
                        "moyenne": 14.5
                      },
                    ];

                    double moyenne = 14.5;

                    await PdfService().generateSemesterPdf(
                      "Semestre 1",
                      subjects,
                      moyenne,
                      selectedFaculty!,
                      selectedDepartment!,
                      selectedLevel!,
                    );
                  },
                  child: Text("Générer le PDF"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}