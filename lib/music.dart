import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  final List<Map<String, String>> musicList = [
    {'name': '364hz', 'image': 'assets/music_image1.png', 'audio': 'assets/audio/music1.mp3'},
    {'name': '465hz', 'image': 'assets/music_image2.png', 'audio': 'assets/audio/music2.mp3'},
    {'name': '528hz', 'image': 'assets/music_image3.png', 'audio': 'assets/audio/music3.mp3'},
    {'name': '639hz', 'image': 'assets/music_image4.png', 'audio': 'assets/audio/music4.mp3'},
    {'name': '741hz', 'image': 'assets/music_image5.png', 'audio': 'assets/audio/music5.mp3'},
    {'name': '852hz', 'image': 'assets/music_image6.jpg', 'audio': 'assets/audio/music6.mp3'},
  ];

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration? _duration;
  Duration? _position;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMusic(String audioPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(audioPath, isLocal: true);
  }

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harmony Healing'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: musicList.map((music) {
                  return GestureDetector(
                    onTap: () => _playMusic(music['audio']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(music['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            music['name']!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${_formatDuration(_position ?? Duration.zero)} / ${_formatDuration(_duration ?? Duration.zero)}',
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    if ((_position ?? Duration.zero).inSeconds > 10) {
                      _audioPlayer.seek(Duration(seconds: (_position?.inSeconds ?? 0) - 10));
                    } else {
                      _audioPlayer.seek(Duration(seconds: 0));
                    }
                  },
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    if ((_position ?? Duration.zero) + Duration(seconds: 10) < (_duration ?? Duration.zero)) {
                      _audioPlayer.seek(Duration(seconds: (_position?.inSeconds ?? 0) + 10));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
