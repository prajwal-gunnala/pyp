// chatbot.dart
import 'package:flutter/material.dart';

class Puzzle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('games'),
      ),
      body: Center(
        child: Text(
          'This is the games page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
