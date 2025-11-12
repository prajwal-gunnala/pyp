import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: SplashScreen(),
    );
  }
}

