// chatbot.dart
import 'package:flutter/material.dart';

class FlowFree extends StatelessWidget {
  const FlowFree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('games'),
      ),
      body: const Center(
        child: Text(
          'This is the games page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
