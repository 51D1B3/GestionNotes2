import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/about_screen.dart';
import 'package:notes_app/screens/backup_screen.dart';
import 'package:notes_app/screens/change_pin_screen.dart';
import 'package:notes_app/services/theme_provider.dart';
import 'package:notes_app/widgets/custom_page_route.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showFontSizeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Taille de la police"),
          content: SizedBox(
            height: 200,
            width: 100,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.2,
              controller: FixedExtentScrollController(initialItem: provider.fontSize.toInt() - 8),
              onSelectedItemChanged: (index) => provider.setFontSize((8 + index).toDouble()),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final size = 8 + index;
                  final isSelected = size == provider.fontSize.toInt();
                  return Center(
                    child: Text(
                      size.toString(), 
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null
                      ),
                    )
                  );
                },
                childCount: 13, // 8 to 20
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choisir la langue"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Français"),
              trailing: context.locale.languageCode == 'fr' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () { context.setLocale(const Locale('fr')); Navigator.pop(context); }
            ),
            ListTile(
              title: const Text("English"),
              trailing: context.locale.languageCode == 'en' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () { context.setLocale(const Locale('en')); Navigator.pop(context); }
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: ListView(
        children: [
           SwitchListTile(
              title: Text('dark_mode'.tr()),
              secondary: const Icon(Icons.dark_mode),
              value: context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ListTile(
            leading: const Icon(Icons.lock), 
            title: Text('change_pin'.tr()),
            onTap: () => Navigator.push(context, CustomPageRoute(builder: (context) => const ChangePinScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text('backup_sync'.tr()),
            onTap: () => Navigator.push(context, CustomPageRoute(builder: (context) => const BackupScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language'.tr()),
            subtitle: Text(context.locale.languageCode == 'fr' ? "Français" : "English"),
            onTap: () => _showLanguageDialog(context, themeProvider),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text('font_size'.tr()),
            subtitle: Text(context.watch<ThemeProvider>().fontSize.toInt().toString()),
            onTap: () => _showFontSizeDialog(context, themeProvider),
          ),
           const Divider(),
           ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('about'.tr()),
            onTap: () => Navigator.push(context, CustomPageRoute(builder: (context) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}
