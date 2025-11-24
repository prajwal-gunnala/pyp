import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot.dart';
import 'assessment.dart';
import 'category_page.dart';
import 'profile_page.dart';
import 'calendar_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Welcome', style: GoogleFonts.abrilFatface(fontSize: 24)),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu_rounded, color: Colors.black87),
            offset: Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'categories') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage()),
                );
              } else if (value == 'calendar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()),
                );
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'calendar',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Color(0xFF4CAF50)),
                    SizedBox(width: 12),
                    Text('Wellness Calendar', style: GoogleFonts.lato(fontSize: 16)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category_rounded, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Categories', style: GoogleFonts.lato(fontSize: 16)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Profile', style: GoogleFonts.lato(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Main question
              Text(
                'How are',
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'you',
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4E37),
                ),
              ),
              Text(
                'feeling?',
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 60),
              // AI Chatbot button with icon
              Container(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ChatBot(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.chat_bubble_rounded, size: 28, color: Colors.white),
                  label: Text(
                    'AI Chatbot',
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Assessment button
              Container(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => Assessment(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.assignment_rounded, size: 28, color: Colors.white),
                  label: Text(
                    'Take an Assessment',
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5D4E37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
