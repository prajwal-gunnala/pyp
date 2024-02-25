import 'package:flutter/material.dart';
import 'menu.dart'; // Import the Menu class

class Assessment extends StatefulWidget {
  @override
  _AssessmentState createState() => _AssessmentState();
}

class _AssessmentState extends State<Assessment> {
  List<Map<String, dynamic>> questions = [
   {
  'question': 'Question 1: How often do you feel anxious?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 2: How well do you cope with stress?',
  'options': ['Very well', 'Moderately well', 'Not very well', 'Not at all well'],
  'selected': '',
},
{
  'question': 'Question 3: How often do you feel depressed?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 4: How often do you feel overwhelmed?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 5: How well do you sleep at night?',
  'options': ['Very well', 'Moderately well', 'Not very well', 'Not at all well'],
  'selected': '',
},
{
  'question': 'Question 6: How often do you experience mood swings?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 7: How often do you feel lonely?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 8: How often do you experience racing thoughts?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 9: How often do you feel hopeless?',
  'options': ['Never', 'Sometimes', 'Often', 'Always'],
  'selected': '',
},
{
  'question': 'Question 10: How often do you engage in self-care activities?',
  'options': ['Everyday', 'Several times a week', 'Rarely', 'Never'],
  'selected': '',
}

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[index]['question'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: questions[index]['options'].length,
                      itemBuilder: (context, optionIndex) {
                        return RadioListTile(
                          title: Text(questions[index]['options'][optionIndex]),
                          value: questions[index]['options'][optionIndex],
                          groupValue: questions[index]['selected'],
                          onChanged: (value) {
                            setState(() {
                              questions[index]['selected'] = value;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        SizedBox(height: 20),
          Center( // Center the button horizontally
            child: ElevatedButton(
              onPressed: () {
                // Logic to proceed to the next page (Menu page)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Menu()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(Icons.arrow_right, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
