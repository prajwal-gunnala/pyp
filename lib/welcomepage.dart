import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),
              // Logo
              Center(
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Motivational text
              Text(
                'Taking',
                style: GoogleFonts.abrilFatface(
                  fontSize: 36,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              Text(
                'action is',
                style: GoogleFonts.abrilFatface(
                  fontSize: 36,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              Text(
                'difficult but',
                style: GoogleFonts.abrilFatface(
                  fontSize: 36,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              Text(
                'it is',
                style: GoogleFonts.abrilFatface(
                  fontSize: 36,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
              Text(
                'necessary',
                style: GoogleFonts.abrilFatface(
                  fontSize: 36,
                  height: 1.3,
                  color: const Color(0xFF5D4E37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Modern button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Let\'s get started',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
