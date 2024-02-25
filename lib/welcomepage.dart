import 'package:flutter/material.dart';
import 'homepage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // This removes the app bar
        child: AppBar(
          backgroundColor: Color(0xFFDBC59C), // Set app bar color same as background color
          elevation: 0, // Remove shadow
        ),
      ),
      body: Container(
        color: Color(0xF3EDE0), // Background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
              child: Image.asset(
                'assets/logo.png', // Adjust the path to your logo image
                width: 250,
                height: 250,
              ),
            ),
            SizedBox(height: 10),
           Padding(
  padding: const EdgeInsets.only(left: 20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Taking',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'action is',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'difficult but',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'it is',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'necessary',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

         SizedBox(height: 80),
          Container(
  alignment: Alignment.center,
  child: SizedBox(
    width: 200, // Adjust width as needed
    height: 50, // Adjust height as needed
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
      child: Text(
        'Let\'s get started',
        style: TextStyle(color: Colors.white,fontSize: 20),
        
      ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
