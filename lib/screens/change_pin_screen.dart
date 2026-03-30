import 'package:flutter/material.dart';
import 'package:notes_app/services/firestore_service.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();

  bool _isOldPinVerified = false;

  void _verifyOldPin() async {
    if (_oldPinController.text.length != 4) return;

    final isCorrect = await _service.verifyPin(_oldPinController.text);
    if (isCorrect) {
      setState(() {
        _isOldPinVerified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ancien PIN incorrect."), backgroundColor: Colors.red),
      );
      _oldPinController.clear();
    }
  }

  void _updatePin() {
    if (_newPinController.text.length != 4) return;

    _service.updatePin(_newPinController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Code PIN mis à jour."), backgroundColor: Color(0xFF00A8E8)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Modifier le PIN', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : const Color(0xFF0A3D62),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isOldPinVerified ? Icons.lock_person_rounded : Icons.lock_outline_rounded,
                size: 60,
                color: const Color(0xFF3CDEED),
              ),
              const SizedBox(height: 20),
              if (!_isOldPinVerified)
                ...[
                  Text("Ancien code PIN", 
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87), 
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _oldPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, letterSpacing: 10, color: Color(0xFF3CDEED)),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton("VÉRIFIER", _verifyOldPin),
                ]
              else
                ...[
                  Text("Nouveau code PIN", 
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87), 
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _newPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, letterSpacing: 10, color: Color(0xFF3CDEED)),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton("METTRE À JOUR", _updatePin),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A8E8).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2E36),
          foregroundColor: const Color(0xFF3CDEED),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF3CDEED), width: 1),
          ),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }
}
