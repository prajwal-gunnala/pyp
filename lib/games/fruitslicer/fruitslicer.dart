
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'canvas_area/canvas_area.dart';

class FruitSlicer extends StatefulWidget {
  @override
  _FruitSlicerState createState() => _FruitSlicerState();
}

class _FruitSlicerState extends State<FruitSlicer> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
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
