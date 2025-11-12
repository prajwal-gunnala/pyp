import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'music.dart';
import 'games.dart';
import 'doctor.dart';
import 'widgets/modern_card.dart';

class CategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Categories', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            buildModernSection(
              context,
              'Music Therapy',
              [
                {'image': 'assets/music_image1.png', 'title': '432 Hz - Healing'},
                {'image': 'assets/music_image2.png', 'title': '528 Hz - Love'},
                {'image': 'assets/music_image3.png', 'title': '639 Hz - Connection'},
                {'image': 'assets/music_image4.png', 'title': '741 Hz - Expression'},
                {'image': 'assets/music_image5.png', 'title': '852 Hz - Intuition'},
                {'image': 'assets/music_image6.jpg', 'title': '963 Hz - Awakening'},
              ],
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllMusicPage()),
                );
              },
            ),
            SizedBox(height: 30),
            buildModernSection(
              context,
              'Mind Games',
              [
                {'image': 'assets/games_image1.jpeg', 'title': 'Tic Tac Toe'},
                {'image': 'assets/games_image2.jpeg', 'title': 'Puzzle'},
                {'image': 'assets/games_image3.png', 'title': 'Flow Free'},
                {'image': 'assets/games_image4.png', 'title': 'Memory Game'},
              ],
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllGamesPage()),
                );
              },
            ),
            SizedBox(height: 30),
            buildModernSection(
              context,
              'Consultants',
              [
                {'image': 'assets/consultant_image1.jpg', 'title': 'Dr. Sarah Johnson'},
                {'image': 'assets/consultant_image2.jpeg', 'title': 'Dr. Michael Chen'},
                {'image': 'assets/consultant_image3.jpeg', 'title': 'Dr. Emily Davis'},
                {'image': 'assets/consultant_image4.jpeg', 'title': 'Dr. James Wilson'},
                {'image': 'assets/consultant_image5.png', 'title': 'Dr. Lisa Anderson'},
              ],
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllConsultantsPage()),
                );
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildModernSection(
    BuildContext context,
    String title,
    List<Map<String, String>> items,
    VoidCallback onSeeAll,
  ) {
    // Limit to 10 items for scrollable view
    List<Map<String, String>> limitedItems = items.take(10).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.abrilFatface(fontSize: 22, color: Colors.black87),
              ),
              InkWell(
                onTap: onSeeAll,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: limitedItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ModernImageCard(
                  imagePath: limitedItems[index]['image']!,
                  title: limitedItems[index]['title']!,
                  width: 280,
                  onTap: () {
                    // Handle tap if needed
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// All Music Page
class AllMusicPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('All Music Therapy', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Music()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Go to Music Player',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// All Games Page
class AllGamesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('All Mind Games', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Games()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Go to Games',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// All Consultants Page
class AllConsultantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('All Consultants', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Doctor()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Go to Consultants',
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
