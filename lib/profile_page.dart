import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/user_profile_service.dart';
import 'services/diary_service.dart';
import 'services/micro_tasks_service.dart';
import 'diary_page.dart';
import 'micro_tasks_page.dart';
import 'calendar_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'User';
  int _sessions = 0;
  int _assessments = 0;
  int _musicPlays = 0;
  int _gamesPlayed = 0;
  int _streak = 0;
  int _daysSinceStart = 0;
  int _diaryEntries = 0;
  int _tasksCompleted = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final name = await UserProfileService.getUserName();
      final sessions = await UserProfileService.getSessionsCount();
      final assessments = await UserProfileService.getAssessmentsTakenCount();
      final music = await UserProfileService.getMusicPlaysCount();
      final games = await UserProfileService.getGamesPlayedCount();
      final streak = await UserProfileService.getStreak();
      final days = await UserProfileService.getDaysSinceFirstLaunch();
      
      // Get diary and tasks stats
      final diaryCount = await DiaryService.getEntryCount();
      final tasksCount = await MicroTasksService.getTotalCompletedCount();

      if (!mounted) return;

      setState(() {
        _userName = name ?? 'User';
        _sessions = sessions;
        _assessments = assessments;
        _musicPlays = music;
        _gamesPlayed = games;
        _streak = streak;
        _daysSinceStart = days;
        _diaryEntries = diaryCount;
        _tasksCompleted = tasksCount;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3EDE0),
        appBar: AppBar(
          title: Text('Profile', style: GoogleFonts.abrilFatface()),
          backgroundColor: const Color(0xFFF3EDE0),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.abrilFatface()),
        backgroundColor: const Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black87,
                  child: Icon(Icons.person_rounded, size: 60, color: Color(0xFFF3EDE0)),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: GoogleFonts.abrilFatface(fontSize: 28, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Taking care of your mental health',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Streak card - highlight this for engagement
          if (_streak > 0)
            _buildStreakCard(),
          if (_streak > 0)
            const SizedBox(height: 16),
          
          // Activity stats - real data
          _buildProfileCard(
            'Your Progress',
            [
              _buildInfoRow(Icons.chat_rounded, 'Chat Sessions', '$_sessions ${_sessions == 1 ? 'conversation' : 'conversations'}'),
              _buildInfoRow(Icons.assessment_rounded, 'Assessments', '$_assessments completed'),
              _buildInfoRow(Icons.book_outlined, 'Journal Entries', '$_diaryEntries ${_diaryEntries == 1 ? 'entry' : 'entries'}'),
              _buildInfoRow(Icons.check_circle_outline, 'Tasks Completed', '$_tasksCompleted total'),
              _buildInfoRow(Icons.music_note_rounded, 'Music Listened', '$_musicPlays ${_musicPlays == 1 ? 'session' : 'sessions'}'),
              _buildInfoRow(Icons.games_rounded, 'Games Played', '$_gamesPlayed ${_gamesPlayed == 1 ? 'time' : 'times'}'),
              if (_daysSinceStart > 0)
                _buildInfoRow(Icons.calendar_today_rounded, 'Days with us', '$_daysSinceStart ${_daysSinceStart == 1 ? 'day' : 'days'}'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Wellness Tools - NEW
          _buildWellnessToolsCard(),
          const SizedBox(height: 16),
          
          // Consultation Documents card
          _buildProfileCard(
            'Consultation Documents',
            [
              _buildDocumentRow('Initial Assessment', 'March 15, 3002', Icons.description_rounded),
              _buildDocumentRow('Therapy Session Notes', 'April 2, 3002', Icons.note_alt_rounded),
              _buildDocumentRow('Treatment Plan', 'April 10, 3002', Icons.medical_information_rounded),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bookings with Consultant card
          _buildProfileCard(
            'Bookings with Consultant',
            [
              _buildBookingRow('Dr. Sarah Mitchell', 'Next Session: May 25, 3002', '10:00 AM'),
              _buildBookingRow('Dr. James Rodriguez', 'Last Session: May 10, 3002', '2:30 PM'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Settings button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                // Settings functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings coming soon!', style: GoogleFonts.lato())),
                );
              },
              icon: const Icon(Icons.settings_rounded),
              label: Text(
                'Settings',
                style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Engaging streak card to encourage daily use
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B7355),
            Color(0xFF5D4E37),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_streak Day${_streak == 1 ? '' : 's'} Streak!',
                  style: GoogleFonts.abrilFatface(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep up your daily wellness journey',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Wellness tools navigation card
  Widget _buildWellnessToolsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wellness Tools',
            style: GoogleFonts.abrilFatface(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          // NEW: Calendar button - prominent position at top
          _buildToolButton(
            icon: Icons.calendar_month_rounded,
            label: 'Wellness Calendar',
            description: 'Track your daily progress',
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.book_outlined,
            label: 'My Journal',
            description: 'Write about your feelings',
            color: const Color(0xFF5D4E37),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiaryPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.check_circle_outline,
            label: 'Daily Tasks',
            description: 'Small steps to wellness',
            color: const Color(0xFF8B7355),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MicroTasksPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.abrilFatface(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDE0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF5D4E37), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 16),
        ],
      ),
    );
  }

  Widget _buildBookingRow(String doctorName, String sessionInfo, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF5D4E37),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sessionInfo,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: const Color(0xFF5D4E37),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
