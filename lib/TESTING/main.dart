import 'package:flutter/material.dart';
import 'merge_cam_det.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: CameraFaceDetectionWidget(),
      ),
    );
  }
}
