import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Doctor extends StatelessWidget {
  final List<Map<String, dynamic>> consultantData = [
    {
      'name': 'Dr. Rachael',
      'designation': 'Psychiatrist',
      'experience': '10 years',
      'image': 'assets/consultant_image1.jpg',
      'contact': '+1234567890',
    },
    {
      'name': 'Dr. Jane Smith',
      'designation': 'Therapist',
      'experience': '8 years',
      'image': 'assets/consultant_image2.jpeg',
      'contact': '+9876543210',
    },
    {
      'name': 'Dr. Michael Johnson',
      'designation': 'Psychologist',
      'experience': '12 years',
      'image': 'assets/consultant_image3.jpeg',
      'contact': '+2468101214',
    },
    {
      'name': 'Dr. Emily Brown',
      'designation': 'Counselor',
      'experience': '6 years',
      'image': 'assets/consultant_image4.jpeg',
      'contact': '+1357913579',
    },
    {
      'name': 'Dr. Alex Wilson',
      'designation': 'Psychiatrist',
      'experience': '15 years',
      'image': 'assets/consultant_image5.png',
      'contact': '+1122334455',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Mental Health Consultants', style: GoogleFonts.abrilFatface(fontSize: 22)),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: consultantData.length,
        itemBuilder: (context, index) {
          final doctor = consultantData[index];
          return DoctorCard(
            name: doctor['name'],
            designation: doctor['designation'],
            experience: doctor['experience'],
            imagePath: doctor['image'],
            rating: 4.8,
            availableTimes: ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM'],
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String designation;
  final String experience;
  final String imagePath;
  final double rating;
  final List<String> availableTimes;

  const DoctorCard({
    required this.name,
    required this.designation,
    required this.experience,
    required this.imagePath,
    required this.rating,
    required this.availableTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Header with Image and Info
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Doctor Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF8B7355), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.abrilFatface(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        designation,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Color(0xFF8B7355),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 14, color: Colors.black54),
                          SizedBox(width: 4),
                          Text(
                            experience,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.grey[300], thickness: 1),
          ),
          
          // Available Times
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Times',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTimes.map((time) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3EDE0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFF8B7355).withOpacity(0.3)),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Color(0xFF8B7355),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Book Appointment Button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking appointment with $name...'),
                      backgroundColor: Color(0xFF8B7355),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B7355),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Book Appointment',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
