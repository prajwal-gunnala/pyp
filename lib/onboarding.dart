import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assessment.dart';
import 'chatbot.dart';
import 'services/user_profile_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await UserProfileService.setUserName(name);

    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToChat() async {
    await UserProfileService.incrementSessions();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChatBot()),
    );
  }

  Color get _bg => const Color(0xFFF3EDE0);
  TextStyle get _titleStyle => GoogleFonts.abrilFatface(
        fontSize: 32,
        color: Colors.black87,
      );
  TextStyle get _bodyStyle => GoogleFonts.lato(
        fontSize: 16,
        height: 1.5,
        color: Colors.black54,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_pageIndex + 1) / 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  _buildIntroPage(),
                  _buildNamePage(),
                  _buildQuoteAndAssessmentTeaserPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('Welcome', style: _titleStyle.copyWith(fontSize: 40)),
          Text('you\'re in a safe space',
              style: _titleStyle.copyWith(fontSize: 26, color: const Color(0xFF5D4E37))),
          const SizedBox(height: 32),
          Text(
            'This app is here to gently support your mental health journey with small steps, '
            'calming sounds, playful games and a friendly chat companion.',
            style: _bodyStyle,
          ),
          const SizedBox(height: 16),
          Text(
            'It is not a replacement for professional help. If you are in crisis or in danger, '
            'please contact local emergency services or a trusted helpline.',
            style: _bodyStyle.copyWith(color: Colors.black87),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              child: Text('I understand', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('What should we call you?', style: _titleStyle),
          const SizedBox(height: 16),
          Text(
            'Your name helps the companion talk to you in a more personal, warm way.',
            style: _bodyStyle,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: GoogleFonts.lato(color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveNameAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4E37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              child: Text('Continue', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuoteAndAssessmentTeaserPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('A good step', style: _titleStyle.copyWith(fontSize: 34)),
          const SizedBox(height: 16),
          Text(
            'Just opening this app is an act of taking care of yourself. You don\'t have to fix '
            'everything today — we\'ll go one small step at a time.',
            style: _bodyStyle,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before we start chatting, we\'ll ask you 5 quick questions to get a rough feel '
                  'for how you\'ve been.',
                  style: _bodyStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  'There are no right or wrong answers. It just helps the companion respond more '
                  'gently to where you are today.',
                  style: _bodyStyle,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => Assessment()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              child: Text('Start the 5‑question check‑in',
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can always skip ahead and come back to questions later from the menu.',
            style: _bodyStyle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
