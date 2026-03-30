import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/onboarding_screen.dart';
import 'package:notes_app/screens/pin_screen.dart';
import 'package:notes_app/screens/profile_setup_screen.dart';
import 'package:notes_app/services/theme_provider.dart';
import 'package:notes_app/services/university_setup_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    UniversitySetupService().initializeFaculties();
  } catch (e) {
    debugPrint("Erreur initialisation Firebase: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final isProfileSet = prefs.getBool('isProfileSet') ?? false;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('fr'),
      useOnlyLangCode: true,
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(hasSeenOnboarding: hasSeenOnboarding, isProfileSet: isProfileSet),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isProfileSet;
  const MyApp({super.key, required this.hasSeenOnboarding, required this.isProfileSet});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final fontSize = themeProvider.fontSize;
        
        TextTheme buildTextTheme(TextTheme base, Color color) {
          return base.copyWith(
            bodyLarge: base.bodyLarge?.copyWith(fontSize: fontSize + 2, color: color, fontFamily: 'Poppins'),
            bodyMedium: base.bodyMedium?.copyWith(fontSize: fontSize, color: color, fontFamily: 'Poppins'),
            titleLarge: base.titleLarge?.copyWith(fontSize: fontSize + 6, color: color, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            labelLarge: base.labelLarge?.copyWith(fontSize: fontSize, color: color, fontFamily: 'Poppins'),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "UniNotes",
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, 
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0A3D62),
            scaffoldBackgroundColor: const Color(0xFFF0F4F8),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A3D62),
              primary: const Color(0xFF0A3D62),
              secondary: const Color(0xFF3CDEED),
            ),
            textTheme: buildTextTheme(ThemeData.light().textTheme, Colors.black87),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color(0xFF0A3D62),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF051923),
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00A8E8),
              secondary: Color(0xFF3CDEED),
              surface: Color(0xFF0A2E36),
            ),
            textTheme: buildTextTheme(ThemeData.dark().textTheme, Colors.white),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.black,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          home: AuthWrapper(hasSeenOnboarding: hasSeenOnboarding, isProfileSet: isProfileSet),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final bool hasSeenOnboarding;
  final bool isProfileSet;
  const AuthWrapper({super.key, this.hasSeenOnboarding = true, this.isProfileSet = false});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  String? _error;
  bool _isProfileLocal = false;

  @override
  void initState() {
    super.initState();
    _isProfileLocal = widget.isProfileSet;
    _startApp();
  }

  Future<void> _startApp() async {
    try {
      // Connexion anonyme si nécessaire
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      if (!_isProfileLocal) {
        setState(() => _error = "Connexion internet requise pour la première configuration.");
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset('assets/applogo.png', height: 100, width: 100, fit: BoxFit.contain),
        ),
      );
    }

    if (_error != null && !_isProfileLocal) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {
                  setState(() { _error = null; _showSplash = true; });
                  _startApp();
                }, child: const Text("Réessayer"))
              ],
            ),
          ),
        ),
      );
    }

    if (!widget.hasSeenOnboarding) return const OnboardingScreen();
    if (!_isProfileLocal) return const ProfileSetupScreen();

    return const PinScreen();
  }
}
