import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/faculties_screen.dart';
import 'package:notes_app/screens/help_screen.dart';
import 'package:notes_app/screens/history_screen.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/screens/semesters_list_screen.dart';
import 'package:notes_app/screens/settings_screen.dart';
import 'package:notes_app/screens/statistics_screen.dart';
import 'package:notes_app/screens/profile_setup_screen.dart';
import 'package:notes_app/services/firestore_service.dart';
import 'package:notes_app/widgets/custom_page_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService service = FirestoreService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF051923) : Colors.white,
      child: Column(
        children: <Widget>[
          FutureBuilder<Map<String, String>?>(
            future: service.getProfile(),
            builder: (context, snapshot) {
              String? photoUrl = snapshot.data?['photoUrl'];

              // Déterminer l'image à afficher (Avatar local ou Logo)
              ImageProvider imageProvider;
              if (photoUrl != null && photoUrl.startsWith('assets/')) {
                imageProvider = AssetImage(photoUrl);
              } else {
                imageProvider = const AssetImage('assets/applogo.png');
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                      ? [const Color(0xFF0A2E36), const Color(0xFF051923)]
                      : [const Color(0xFF0A3D62), const Color(0xFF1E3799)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)]),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: isDark ? const Color(0xFF051923) : Colors.white,
                        backgroundImage: imageProvider,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (snapshot.hasData)
                      Text(
                        "${snapshot.data!['firstName']} ${snapshot.data!['lastName']}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, Icons.home_outlined, 'Home'.tr(), const HomeScreen(), true),
                _buildMenuItem(context, Icons.person_outline, 'Profil', const ProfileSetupScreen(isEditing: true), false),
                _buildMenuItem(context, Icons.school_outlined, 'Semester Averages'.tr(), const SemestersListScreen(), false),
                _buildMenuItem(context, Icons.business_outlined, 'Faculties'.tr(), const FacultiesScreen(), false),
                _buildMenuItem(context, Icons.bar_chart_outlined, 'Statistics'.tr(), const StatisticsScreen(), false),
                _buildMenuItem(context, Icons.history_outlined, 'History'.tr(), const HistoryScreen(), false),
                const Divider(color: Colors.white10),
                _buildMenuItem(context, Icons.settings_outlined, 'settings_title'.tr(), const SettingsScreen(), false),
                _buildMenuItem(context, Icons.help_outline, 'Help'.tr(), const HelpScreen(), false),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: Text('Exit'.tr(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => SystemNavigator.pop(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget destination, bool isReplacement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3CDEED)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        if (isReplacement) {
          Navigator.pushReplacement(context, CustomPageRoute(builder: (context) => destination));
        } else {
          Navigator.push(context, CustomPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
