
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/developpeur.jpg'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mahamadou Sidibé',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text("Etudiant à l'université de Labé"),
                      Text("Faculté FST au département MIAGE"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "👨🏾‍💻À propos du développeur👨‍💻 \n\n"
              "Mahamadou Sidibé est un développeur passionné par les technologies Web, mobiles et les solutions numériques innovantes. "
              "Spécialisé en développement d’applications, il conçoit des outils modernes, simples et efficaces pour améliorer l’expérience des étudiants. "
              "À travers cette application, son objectif est d’aider les étudiants guinéens à mieux organiser leurs semestres, suivre leurs performances académiques et réussir en adoptant des méthodes stratégiques simples et efficaces. "
              "Toujours en quête d’excellence, il met un point d’honneur à créer une application professionnelle, sécurisée et intuitive. \n\n"
              "📧 Informations de contact \n"
              "Email : ma-sidibe-fst.miage@univ-labe.edu.gn \n",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const Text(
              'Version 1.0.1',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
