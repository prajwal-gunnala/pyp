import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'onboarding.dart';
import 'homepage.dart';
import 'services/user_profile_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PYP - Prompt Your Problems',
      theme: ThemeData(
        primaryColor: Color(0xFFDBC59C),
        scaffoldBackgroundColor: Color(0xFFF3EDE0),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFDBC59C),
          secondary: Color(0xFF8B7355),
          surface: Color(0xFFF3EDE0),
          background: Color(0xFFF3EDE0),
        ),
        // Font hierarchy using different Google Fonts
        textTheme: TextTheme(
          displayLarge: GoogleFonts.abrilFatface(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          displayMedium: GoogleFonts.abrilFatface(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          displaySmall: GoogleFonts.kumarOne(fontSize: 24, color: Colors.black87),
          headlineMedium: GoogleFonts.pacifico(fontSize: 20, color: Colors.black87),
          titleLarge: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          bodyLarge: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
          bodyMedium: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
          labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF3EDE0),
          elevation: 0,
          titleTextStyle: GoogleFonts.abrilFatface(fontSize: 22, color: Colors.black87),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const _RootDecider(),
    );
  }
}

class _RootDecider extends StatefulWidget {
  const _RootDecider({Key? key}) : super(key: key);

  @override
  State<_RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<_RootDecider> {
  bool _loading = true;
  bool _hasProfile = false;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the very first app launch
    final hasLaunched = prefs.getBool('has_launched_before') ?? false;
    
    // Check if user has completed onboarding
    final name = await UserProfileService.getUserName();
    
    setState(() {
      _hasProfile = name != null && name.trim().isNotEmpty;
      _isFirstLaunch = !hasLaunched;
      _loading = false;
    });
    
    // Mark that app has been launched
    if (!hasLaunched) {
      await prefs.setBool('has_launched_before', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Show splash only during initial loading
      return SplashScreen();
    }
    
    // First time user: show onboarding
    if (!_hasProfile) {
      return const OnboardingFlow();
    }
    
    // Very first launch after onboarding: show splash with transition
    if (_isFirstLaunch) {
      return SplashScreen();
    }
    
    // Returning user: go straight to HomePage (no splash delay!)
    return HomePage();
  }
}

