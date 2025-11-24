
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'canvas_area/canvas_area.dart';
import '../../services/user_profile_service.dart';

class FruitSlicer extends StatefulWidget {
  @override
  _FruitSlicerState createState() => _FruitSlicerState();
}

class _FruitSlicerState extends State<FruitSlicer> {
  bool _hasTrackedPlay = false;

  @override
  void initState() {
    super.initState();
    
    _trackGamePlay();
    
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  Future<void> _trackGamePlay() async {
    if (!_hasTrackedPlay) {
      await UserProfileService.incrementGamesPlayed();
      _hasTrackedPlay = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black54,
        body: CanvasArea(),
      ),
    );
  }
}
