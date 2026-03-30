import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/firestore_service.dart';

class CreateSemesterScreen extends StatefulWidget {
  final bool hasExistingSemesters;

  const CreateSemesterScreen({super.key, required this.hasExistingSemesters});

  @override
  _CreateSemesterScreenState createState() => _CreateSemesterScreenState();
}

class _CreateSemesterScreenState extends State<CreateSemesterScreen> {
  late final PageController _pageController;
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedLicence;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedSemesterName;

  List<String> _titles = [];
  List<Widget> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupPages();
  }

  void _setupPages() {
    if (widget.hasExistingSemesters) {
      _pages = [_buildLicencePage(), _buildSemesterPage()];
      _titles = ["Quelle est votre licence ?", "Choisissez le semestre"];
    } else {
      _pages = [_buildLicencePage(), _buildFacultyPage(), _buildDepartmentPage(), _buildSemesterPage()];
      _titles = ["Quelle est votre licence ?", "Votre faculté ?", "Quel est votre département ?", "Choisissez le semestre"];
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _onLicenceSelected(String licence) {
    setState(() {
      _selectedLicence = licence;
      _setupPages();
    });
    _nextPage();
  }

  void _onFacultySelected(String faculty) {
    setState(() {
      _selectedFaculty = faculty;
      _setupPages();
    });
    _nextPage();
  }

  void _onDepartmentSelected(String department) {
    setState(() => _selectedDepartment = department);
    _nextPage();
  }

  void _onSemesterSelected(String semester) {
    setState(() => _selectedSemesterName = semester);
    _createSemester();
  }

  void _createSemester() {
    if (widget.hasExistingSemesters && _selectedLicence != null && _selectedSemesterName != null) {
      // Pour le mode hors-ligne, on récupère les infos depuis le cache si possible
      _firestoreService.getSemesters().first.then((snap) {
        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data() as Map<String, dynamic>;
          _performCreate(data['faculty'], data['department']);
        }
      });
    } else if (_selectedLicence != null && _selectedFaculty != null && _selectedDepartment != null && _selectedSemesterName != null) {
      _performCreate(_selectedFaculty!, _selectedDepartment!);
    }
  }

  void _performCreate(String faculty, String department) {
    // On lance la création sans await pour fermer l'écran immédiatement
    _firestoreService.addSemester(
      _selectedSemesterName!,
      faculty,
      department,
      _selectedLicence!,
    );
    Navigator.pop(context); // Fermeture immédiate
  }

  Widget _buildSelectionList({required List<String> items, required ValueChanged<String> onItemSelected}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            title: Center(child: Text(items[index].tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            onTap: () => onItemSelected(items[index]),
          ),
        );
      },
    );
  }

  Widget _buildLicencePage() {
    return _buildSelectionList(items: ["Licence 1", "Licence 2", "Licence 3"], onItemSelected: _onLicenceSelected);
  }

  Widget _buildFacultyPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getFaculties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final faculties = snapshot.data?.docs.map((doc) => doc['name'] as String).toList() ?? [];
        return _buildSelectionList(items: faculties, onItemSelected: _onFacultySelected);
      },
    );
  }

  Widget _buildDepartmentPage() {
    if (_selectedFaculty == null) return const Center(child: Text("Sélectionnez une faculté."));
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('faculties').where('name', isEqualTo: _selectedFaculty).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final departmentsData = snapshot.data?.docs.isNotEmpty == true ? snapshot.data?.docs.first.get('departments') as List<dynamic>? : [];
        final departments = departmentsData?.map((d) => d.toString()).toList() ?? [];
        return _buildSelectionList(items: departments, onItemSelected: _onDepartmentSelected);
      },
    );
  }

  Widget _buildSemesterPage() {
    List<String> semesters = [];
    if (_selectedLicence == "Licence 1") semesters = ["Semestre 1", "Semestre 2"];
    else if (_selectedLicence == "Licence 2") semesters = ["Semestre 3", "Semestre 4"];
    else if (_selectedLicence == "Licence 3") semesters = ["Semestre 5", "Semestre 6"];
    return _buildSelectionList(items: semesters, onItemSelected: _onSemesterSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles.isNotEmpty ? _titles[_currentPage].tr() : ""),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.1), _pages[index]]),
          );
        },
      ),
    );
  }
}
