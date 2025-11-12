import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot.dart';
import 'games.dart';
import 'music.dart';
import 'doctor.dart';
import 'widgets/modern_card.dart';

import 'package:pyph/games/tictactoe.dart';
import 'package:pyph/games/fruitslicer/fruitslicer.dart';
import 'package:pyph/games/flowfree.dart';
import 'package:pyph/games/puzzle.dart';

class Menu extends StatelessWidget {
  final List<Map<String, dynamic>> musicData = [
    {'name': '364hz', 'image': 'assets/music_image1.png'},
    {'name': '465hz', 'image': 'assets/music_image2.png'},
    {'name': '528hz', 'image': 'assets/music_image3.png'},
    {'name': '639hz', 'image': 'assets/music_image4.png'},
    {'name': '741hz', 'image': 'assets/music_image5.png'},
    {'name': '852hz', 'image': 'assets/music_image6.jpg'},
  ];

  final List<Map<String, dynamic>> gamesData = [
    {'name': 'Tic Tac Toe', 'image': 'assets/games_image1.jpeg', 'route': TicTacToe()},
    {'name': 'Fruit Slicer', 'image': 'assets/games_image2.jpeg', 'route': FruitSlicer()},
    {'name': 'Puzzle', 'image': 'assets/games_image3.png', 'route': Puzzle()},
    {'name': 'Flow Free', 'image': 'assets/games_image4.png', 'route': FlowFree()},
  ];

  final List<Map<String, dynamic>> consultantData = [
    {'name': 'Dr. Rachael', 'designation': 'Psychiatrist', 'experience': '10 years', 'image': 'assets/consultant_image1.jpg'},
    {'name': 'Dr. Jane Smith', 'designation': 'Therapist', 'experience': '8 years', 'image': 'assets/consultant_image2.jpeg'},
    {'name': 'Dr. Michael Johnson', 'designation': 'Psychologist', 'experience': '12 years', 'image': 'assets/consultant_image3.jpeg'},
    {'name': 'Dr. Emily Brown', 'designation': 'Counselor', 'experience': '6 years', 'image': 'assets/consultant_image4.jpeg'},
    {'name': 'Dr. Alex Wilson', 'designation': 'Psychiatrist', 'experience': '15 years', 'image': 'assets/consultant_image5.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection('Harmony Healing', musicData, Music()),
            buildGamesSection('Harmony Quests', gamesData),
            buildSection('Consultants', consultantData, Doctor()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, dynamic>> data, Widget route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ModernImageCard(
                imagePath: data[index]['image'],
                title: data[index]['name'],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
                height: 200,
                width: 160,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildMenuItem(BuildContext context, String name, String imagePath, Widget route) {
    return ModernImageCard(
      imagePath: imagePath,
      title: name,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
      height: 180,
      width: 140,
    );
  }

  Widget buildGamesSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ModernImageCard(
                imagePath: data[index]['image'],
                title: data[index]['name'],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => data[index]['route'])),
                height: 200,
                width: 160,
              );
            },
          ),
        ),
      ],
    );
  }
}
