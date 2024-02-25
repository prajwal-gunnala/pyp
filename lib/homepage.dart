import 'package:flutter/material.dart';
import 'chatbot.dart';
import 'assessment.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'How are\nyou\nfeeling?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
           ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBot()), // Correct the navigation to ChatBot class
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Set button color to black
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.chat, color: Colors.white), // Add your logo here with white color
                  SizedBox(width: 10),
                  Text('AI Chatbot', style: TextStyle(color: Colors.white)), // Set text color to white
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Assessment()), // Correct the navigation to Assessment class
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Set button color to black
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text('Take an Assessment', style: TextStyle(color: Colors.white)), // Set text color to white
            ),
          ],
        ),
      ),
    );
  }
}
