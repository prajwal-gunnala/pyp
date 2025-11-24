import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'services/user_profile_service.dart';
import 'services/wellness_service.dart';

class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  final List<Map<String, String>> musicList = [
    {'name': '432 Hz - Healing', 'image': 'assets/music_image1.png', 'audio': 'assets/audio/music1.mp3'},
    {'name': '528 Hz - Love', 'image': 'assets/music_image2.png', 'audio': 'assets/audio/music2.mp3'},
    {'name': '639 Hz - Connection', 'image': 'assets/music_image3.png', 'audio': 'assets/audio/music3.mp3'},
    {'name': '741 Hz - Expression', 'image': 'assets/music_image4.png', 'audio': 'assets/audio/music4.mp3'},
    {'name': '852 Hz - Intuition', 'image': 'assets/music_image5.png', 'audio': 'assets/audio/music5.mp3'},
    {'name': '963 Hz - Awakening', 'image': 'assets/music_image6.jpg', 'audio': 'assets/audio/music6.mp3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Text('Music Therapy', style: GoogleFonts.abrilFatface()),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          return _buildMusicCard(context, index);
        },
      ),
    );
  }

  Widget _buildMusicCard(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerPage(
              musicData: musicList[index],
              allMusic: musicList,
              initialIndex: index,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                musicList[index]['image']!,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musicList[index]['name']!,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(Icons.play_circle_filled, color: Colors.white, size: 32),
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

// Fullscreen Music Player
class MusicPlayerPage extends StatefulWidget {
  final Map<String, String> musicData;
  final List<Map<String, String>> allMusic;
  final int initialIndex;

  MusicPlayerPage({
    required this.musicData,
    required this.allMusic,
    required this.initialIndex,
  });

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _player = AudioPlayer();
    _initPlayer();
    
    // Record music usage in wellness service
    WellnessService.recordFeatureUsage('music');
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setAsset(widget.allMusic[currentIndex]['audio']!);
      
      _player.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
      
      _player.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      
      _player.playerStateStream.listen((state) {
        setState(() {
          isPlaying = state.playing;
        });
        
        // Auto play next when completed
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      });
      
      // Auto play
      _player.play();
    } catch (e) {
      print('Error loading audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio file')),
      );
    }
  }

  Future<void> _playSong(int index) async {
    try {
      setState(() {
        currentIndex = index;
      });
      
      // Track music play for stats
      await UserProfileService.incrementMusicPlays();
      
      await _player.setAsset(widget.allMusic[index]['audio']!);
      await _player.play();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  void _playNext() {
    if (currentIndex < widget.allMusic.length - 1) {
      _playSong(currentIndex + 1);
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      _playSong(currentIndex - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.allMusic[currentIndex]['image']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Spacer(),
                      Text(
                        'Now Playing',
                        style: GoogleFonts.abrilFatface(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
                Spacer(),
                // Song title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.allMusic[currentIndex]['name']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abrilFatface(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                // Progress bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble() > 0 
                              ? _duration.inSeconds.toDouble() 
                              : 1,
                          onChanged: (value) async {
                            await _player.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous_rounded, color: Colors.white, size: 48),
                      onPressed: currentIndex > 0 ? _playPrevious : null,
                    ),
                    SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 48,
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            _player.pause();
                          } else {
                            _player.play();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next_rounded, color: Colors.white, size: 48),
                      onPressed: currentIndex < widget.allMusic.length - 1 ? _playNext : null,
                    ),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
