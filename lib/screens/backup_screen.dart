
import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde & Synchronisation')),
      body: const Center(
        child: Text(" Aucune sauvegarde et synchronisation effectuée pour le moment."),
      ),
    );
  }
}
