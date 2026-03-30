import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide d\'utilisation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue sur UniNotes', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Votre compagnon idéal pour organiser votre parcours universitaire. Voici comment tirer le meilleur parti de l\'application :'),
            const SizedBox(height: 25),
            
            _buildHelpSection(
              context,
              '1. Gestion des Semestres',
              '• Création : Appuyez sur le bouton (+) à l\'accueil. L\'application vous guidera étape par étape (Licence, Faculté, Département, Semestre).\n'
              '• Flux intelligent : Une fois votre premier semestre créé, les suivants se configurent automatiquement pour vous faire gagner du temps.'
            ),
            
            _buildHelpSection(
              context,
              '2. Saisie des Notes',
              'Cliquez sur un semestre pour accéder à son tableau. Deux modes s\'offrent à vous via le bouton (+) :\n'
              '• Calcul automatique : Saisissez vos notes d\'Examen, DG et Final. La moyenne et la mention sont calculées instantanément.\n'
              '• Saisie manuelle : Pour les matières particulières, saisissez directement la moyenne et la mention sans calcul automatique.'
            ),
            
            _buildHelpSection(
              context,
              '3. Téléchargement & Historique',
              '• Export PDF : L\'icône de téléchargement en haut du tableau génère un relevé officiel avec le logo UniNotes.\n'
              '• Localisation : Vos relevés se retrouvent directement dans le dossier "Download" de votre téléphone.\n'
              '• Historique : Retrouvez et ouvrez tous vos documents téléchargés depuis le menu principal.'
            ),
            
            _buildHelpSection(
              context,
              '4. Statistiques & Progression',
              'Suivez l\'évolution de vos résultats grâce à :\n'
              '• La Moyenne Générale de tout votre parcours.\n'
              '• Des graphiques de progression par semestre limités aux mentions (0 à 4).'
            ),
            
            _buildHelpSection(
              context,
              '5. Mode Hors-ligne & Sync',
              'UniNotes fonctionne sans WiFi. Toutes vos saisies sont enregistrées sur votre téléphone et se synchroniseront avec le serveur dès que vous retrouverez une connexion.'
            ),
            
            _buildHelpSection(
              context,
              '6. Personnalisation',
              'Dans les Paramètres, vous pouvez :\n'
              '• Activer le Mode Sombre pour reposer vos yeux.\n'
              '• Changer la Langue (Français/Anglais).\n'
              '• Ajuster la Taille de la police pour un meilleur confort visuel.'
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const Center(
              child: Text('Version 1.0.1 - Développé par Mahamadou Sidibé',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}
