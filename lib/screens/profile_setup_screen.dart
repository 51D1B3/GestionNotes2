import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import 'pin_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  String _selectedGender = 'Homme';
  String? _selectedAvatar;
  bool _loading = false;
  bool _initialLoading = true;

  final List<String> _maleAvatars = [
    'assets/avatars/h2.png',
    'assets/avatars/h3.png',
    'assets/avatars/h4.png',
    'assets/avatars/h5.png',
    'assets/avatars/h6.png',
    'assets/avatars/h7.jpg',
  ];
  final List<String> _femaleAvatars = [
    'assets/avatars/f1.jpg',
    'assets/avatars/f2.png',
    'assets/avatars/f3.png',
    'assets/avatars/f4.png',
    'assets/avatars/f5.png',
    'assets/avatars/f6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() async {
    try {
      final profile = await _service.getProfile();
      if (profile != null) {
        _lastNameController.text = profile['lastName'] ?? '';
        _firstNameController.text = profile['firstName'] ?? '';
        setState(() {
          _selectedGender = profile['gender'] ?? 'Homme';
          _selectedAvatar = (profile['photoUrl'] != null && profile['photoUrl']!.startsWith('assets/')) 
              ? profile['photoUrl']! 
              : null;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement: $e");
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  void _saveProfile() async {
    String lastName = _lastNameController.text.trim().toUpperCase();
    String firstName = _firstNameController.text.trim();
    if (firstName.isNotEmpty) {
      firstName = firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
    }

    if (lastName.isEmpty || firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs")));
      return;
    }

    setState(() => _loading = true);

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 15));
      }

      await _service.setProfile(lastName, firstName, _selectedGender, photoUrl: _selectedAvatar);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProfileSet', true);

      if (mounted) {
        if (widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil mis à jour"), backgroundColor: Color(0xFF00A8E8)));
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PinScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : Vérifiez votre connexion internet"), backgroundColor: Colors.red));
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A2E36),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        List<String> avatars = _selectedGender == 'Homme' ? _maleAvatars : _femaleAvatars;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choisissez votre avatar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedAvatar = avatars[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatar == avatars[index] ? const Color(0xFF3CDEED) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white10,
                          backgroundImage: AssetImage(avatars[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3CDEED), fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isEditing ? "Profil" : "Configuration", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showAvatarPicker,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)]),
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF0A2E36),
                        backgroundImage: _selectedAvatar != null ? AssetImage(_selectedAvatar!) : null,
                        child: _selectedAvatar == null 
                            ? const Icon(Icons.person, size: 60, color: Color(0xFF3CDEED))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)]),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text("Appuyez sur l'image pour choisir un avatar", style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 30),
              TextField(
                controller: _lastNameController,
                style: const TextStyle(fontSize: 15, color: Colors.white),
                decoration: _buildInputDecoration("NOM", true),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _firstNameController,
                style: const TextStyle(fontSize: 15, color: Colors.white),
                decoration: _buildInputDecoration("Prénom", true),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("Sexe : ", style: TextStyle(fontSize: 15, color: Colors.white)),
                  Radio<String>(
                    value: 'Homme', activeColor: const Color(0xFF3CDEED),
                    groupValue: _selectedGender,
                    onChanged: (val) {
                      setState(() {
                        _selectedGender = val!;
                      });
                    },
                  ),
                  const Text("Homme", style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(width: 10),
                  Radio<String>(
                    value: 'Femme', activeColor: const Color(0xFF3CDEED),
                    groupValue: _selectedGender,
                    onChanged: (val) {
                      setState(() {
                        _selectedGender = val!;
                      });
                    },
                  ),
                  const Text("Femme", style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 35),
              _loading 
                ? const CircularProgressIndicator(color: Color(0xFF3CDEED))
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: const Color(0xFF00A8E8).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2E36),
                        foregroundColor: const Color(0xFF3CDEED),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF3CDEED), width: 1),
                        ),
                        elevation: 0,
                      ),
                      child: Text(widget.isEditing ? "METTRE À JOUR" : "VALIDER", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
