import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('Consultants'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: consultantData
              .map((doctor) => DoctorCard(doctor))
              .toList(),
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;

  DoctorCard(this.doctor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(doctor['image']),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Designation: ${doctor['designation']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Experience: ${doctor['experience']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle 'Book Appointment' button press
                          },
                          child: Text('Book Appointment'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Handle 'Contact' button press
                          },
                          child: Text('Contact'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
