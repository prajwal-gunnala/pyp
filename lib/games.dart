import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'games/tictactoe.dart';
import 'games/puzzle.dart';
import 'games/flowfree.dart';
import 'games/fruitslicer/fruitslicer.dart';
import 'services/wellness_service.dart';

class Games extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Mind Games', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a game to relax and train your mind',
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black54, height: 1.5),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildGameCard(
                    context,
                    'Tic Tac Toe',
                    'Classic strategy game for mental focus',
                    Icons.grid_on_rounded,
                    Colors.blue.shade400,
                    () {
                      WellnessService.recordFeatureUsage('games');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TicTacToe()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    'Fruit Slicer',
                    'Slice fruits for stress relief',
                    Icons.apple_rounded,
                    Colors.orange.shade400,
                    () {
                      WellnessService.recordFeatureUsage('games');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FruitSlicer()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    'Sliding Puzzle',
                    'Enhance problem-solving skills',
                    Icons.apps_rounded,
                    Colors.purple.shade400,
                    () {
                      WellnessService.recordFeatureUsage('games');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Puzzle()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    'Flow Free',
                    'Connect matching colors to relax',
                    Icons.timeline_rounded,
                    Colors.green.shade400,
                    () {
                      WellnessService.recordFeatureUsage('games');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FlowFree()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.abrilFatface(fontSize: 20, color: Colors.black87),
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
