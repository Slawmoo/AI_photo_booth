// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  late FaceDetector faceDetector;
  bool isDetecting = false;
  List<Face> faces = []; // List of detected faces

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras![0], // Get the first available camera
      ResolutionPreset.max, // Use the maximum available resolution
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      startImageStream(); // Start processing the image stream
    });
    faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      performanceMode: FaceDetectorMode.accurate,
    ));
  }

  void startImageStream() {
    controller!.startImageStream((CameraImage cameraImage) async {
      if (!isDetecting) {
        isDetecting = true;
        try {
          final inputImage = await _processCameraImage(cameraImage);
          if (inputImage != null) {
            faces = await faceDetector.processImage(inputImage);
            setState(() {}); // Update the UI with detected faces
          }
        } catch (e) {
          print('Error detecting faces: $e');
        } finally {
          isDetecting = false;
        }
      }
    });
  }

  Future<InputImage?> _processCameraImage(CameraImage image) async {
    // Implementation of image processing logic (similar to _inputImageFromCameraImage)
  }

  @override
  void dispose() {
    controller?.dispose(); // Dispose of the controller when the widget is disposed
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(controller!), // Display the camera feed
          CustomPaint(
            painter: FacePainter(rects: faces.map((e) => e.boundingBox).toList()), // Draw rectangles around detected faces
          ),
          Positioned(
            top: 50,
            child: Image.asset('assets/images/hat.png', width: 100, height: 100), // Use the local asset
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final String imagePath = await takePicture();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePreviewScreen(imagePath: imagePath),
              ),
            );
          } catch (e) {
            print('Failed to take picture: $e');
          }
        },
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<String> takePicture() async {
    if (!controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: select a camera first.'))
      );
      return "s";
    }
    try {
      final image = await controller!.takePicture();
      return image.path;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e'))
      );
      return "s";
    }
  }
}

class FacePainter extends CustomPainter {
  final List<Rect> rects;

  FacePainter({required this.rects});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    for (var rect in rects) {
      canvas.drawRect(rect, paint); // Draw a rectangle around each detected face
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Image"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveImage(context, imagePath),
        tooltip: 'Save Image',
        child: Icon(Icons.save),
      ),
    );
  }

  void saveImage(BuildContext context, String imagePath) async {
    GallerySaver.saveImage(imagePath).then((bool? success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success == true ? 'Image Saved to Gallery' : 'Failed to Save Image'))
      );
    });
  }
}
