import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black87,
                  child: Icon(Icons.person_rounded, size: 60, color: Color(0xFFF3EDE0)),
                ),
                SizedBox(height: 16),
                Text(
                  'Abhinav',
                  style: GoogleFonts.abrilFatface(fontSize: 28, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  'Taking care of your mental health',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          
          // Profile details card
          _buildProfileCard(
            'Personal Information',
            [
              _buildInfoRow(Icons.person_rounded, 'Name', 'Abhinav'),
              _buildInfoRow(Icons.phone_rounded, 'Phone', 'xxxx234'),
              _buildInfoRow(Icons.cake_rounded, 'Date of Birth', 'May 22, 3002'),
            ],
          ),
          SizedBox(height: 16),
          
          // Activity card
          _buildProfileCard(
            'Activity Summary',
            [
              _buildInfoRow(Icons.chat_rounded, 'Chat Sessions', '12 conversations'),
              _buildInfoRow(Icons.assessment_rounded, 'Assessments', '5 completed'),
              _buildInfoRow(Icons.music_note_rounded, 'Music Listened', '8 sessions'),
              _buildInfoRow(Icons.games_rounded, 'Games Played', '15 times'),
            ],
          ),
          SizedBox(height: 16),
          
          // Consultation Documents card
          _buildProfileCard(
            'Consultation Documents',
            [
              _buildDocumentRow('Initial Assessment', 'March 15, 3002', Icons.description_rounded),
              _buildDocumentRow('Therapy Session Notes', 'April 2, 3002', Icons.note_alt_rounded),
              _buildDocumentRow('Treatment Plan', 'April 10, 3002', Icons.medical_information_rounded),
            ],
          ),
          SizedBox(height: 16),
          
          // Bookings with Consultant card
          _buildProfileCard(
            'Bookings with Consultant',
            [
              _buildBookingRow('Dr. Sarah Mitchell', 'Next Session: May 25, 3002', '10:00 AM'),
              _buildBookingRow('Dr. James Rodriguez', 'Last Session: May 10, 3002', '2:30 PM'),
            ],
          ),
          SizedBox(height: 16),
          
          // Settings button
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                // Settings functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings coming soon!')),
                );
              },
              icon: Icon(Icons.settings_rounded),
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

  Widget _buildProfileCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
          SizedBox(height: 16),
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
          SizedBox(width: 12),
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF3EDE0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF5D4E37), size: 20),
          ),
          SizedBox(width: 12),
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
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 16),
        ],
      ),
    );
  }

  Widget _buildBookingRow(String doctorName, String sessionInfo, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF5D4E37),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF3EDE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Color(0xFF5D4E37),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
