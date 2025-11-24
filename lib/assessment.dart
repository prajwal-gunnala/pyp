import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_page.dart';
import 'chatbot.dart';
import 'services/user_profile_service.dart';

class Assessment extends StatefulWidget {
  @override
  _AssessmentState createState() => _AssessmentState();
}

class _AssessmentState extends State<Assessment> {
  int currentQuestionIndex = 0;
  late PageController _pageController;
  
  List<Map<String, dynamic>> questions = [
    {
      'question': 'How often do you feel anxious?',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
      'selected': '',
    },
    {
      'question': 'How well do you cope with stress?',
      'options': ['Very well', 'Moderately well', 'Not very well', 'Not at all well'],
      'selected': '',
    },
    {
      'question': 'How often do you feel depressed?',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
      'selected': '',
    },
    {
      'question': 'How often do you feel overwhelmed?',
      'options': ['Never', 'Sometimes', 'Often', 'Always'],
      'selected': '',
    },
    {
      'question': 'How well do you sleep at night?',
      'options': ['Very well', 'Moderately well', 'Not very well', 'Not at all well'],
      'selected': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestionIndex + 1) / questions.length;
    
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Self Assessment', style: GoogleFonts.abrilFatface()),
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
              }
            },
            itemBuilder: (BuildContext context) => [
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
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            minHeight: 6,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: PageView.builder(
              itemCount: questions.length,
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) => _buildQuestionCard(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.black87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: questions[currentQuestionIndex]['selected'] != ''
                        ? () async {
                            if (currentQuestionIndex < questions.length - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Track assessment completion
                              await UserProfileService.incrementAssessmentsTaken();
                              
                              if (!mounted) return;
                              
                              // After completing the first assessment, go straight to the chat
                              // experience instead of the generic menu.
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ChatBot()),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentQuestionIndex < questions.length - 1 ? 'Next' : 'Complete',
                          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 8),
                        Icon(currentQuestionIndex < questions.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questions[index]['question'],
                style: GoogleFonts.abrilFatface(
                  fontSize: 24,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 30),
              ...List.generate(
                questions[index]['options'].length,
                (optionIndex) {
                  String option = questions[index]['options'][optionIndex];
                  bool isSelected = questions[index]['selected'] == option;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          questions[index]['selected'] = option;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black87 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
