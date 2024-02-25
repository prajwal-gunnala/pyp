import 'package:flutter/material.dart';
import 'chatbot.dart';
import 'games.dart';
import 'music.dart';
import 'doctor.dart'; // Import the Doctor class

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
        title: Text('Analysis'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           buildSection('Harmony Healing', musicData, Music()),
            buildGamesSection('Harmony Quests', gamesData),
            buildSection('Consultants', consultantData, Doctor()),
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return buildMenuItem(context, data[index]['name'], data[index]['image'], route);
            },
          ),
        ),
      ],
    );
  }

  Widget buildMenuItem(BuildContext context, String name, String imagePath, Widget route) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
            ),
            SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGamesSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return buildMenuItem(context, data[index]['name'], data[index]['image'], data[index]['route']);
            },
          ),
        ),
      ],
    );
  }
}
