import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final FirestoreService _service = FirestoreService();
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String? savedPin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    savedPin = await _service.getPin();
    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _validatePin() async {
    String enteredPin = _controllers.map((c) => c.text).join();
    if (enteredPin.length != 4) return;

    if (enteredPin == savedPin || (savedPin == null && enteredPin.length == 4)) {
       if (savedPin == null) {
         await _service.setPin(enteredPin);
       }
      _goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code PIN incorrect", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFF3CDEED))));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Formes de fond
          Positioned(
            top: 200,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00A8E8).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3CDEED).withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône Bouclier + Cadenas centré
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: const Icon(Icons.shield, size: 160, color: Colors.white),
                      ),
                      const Positioned(
                        top: 55,
                        child: Icon(Icons.lock_outline, size: 50, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    savedPin == null ? "Créez votre code PIN" : "Entrez votre code PIN",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 65,
                        height: 90,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          obscureText: true,
                          maxLength: 1,
                          style: const TextStyle(color: Color(0xFF3CDEED), fontSize: 32, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF3CDEED), width: 2),
                            ),
                            fillColor: Colors.white.withOpacity(0.05),
                            filled: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (index == 3 && value.isNotEmpty) {
                              _validatePin();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A8E8).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _validatePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2E36),
                        foregroundColor: const Color(0xFF3CDEED),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: const Color(0xFF3CDEED).withOpacity(0.5), width: 1),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Valider",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
