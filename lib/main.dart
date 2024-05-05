import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';

void main() => runApp(CameraApp());

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isDetecting = false;
  late ui.Image _overlayImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadOverlayImage();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.ultraHigh,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  void _loadOverlayImage() async {
    final ByteData data = await rootBundle.load('assets/hat.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    _overlayImage = fi.image;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<ui.Image> loadImage(String imagePath) async {
    final Uint8List data = await File(imagePath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
  Future<void> _detectFacesAndOverlayImage(XFile picture) async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
    });

    final inputImage = InputImage.fromFilePath(picture.path);
    final faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ));
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
  // Create a canvas to draw on the original picture
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint();

  // Load the original picture
  final ui.Image originalImage = await loadImage(picture.path);

  // Draw the original picture on the canvas
  canvas.drawImage(originalImage, Offset.zero, paint);

  // Iterate over all detected faces and draw the overlay image
  for (final Face face in faces) {
    final Rect boundingBox = face.boundingBox;

    // Calculate the position to place the overlay image
    final double overlayX = boundingBox.left;
    final double overlayY = boundingBox.top - (_overlayImage.height / 2);

    // Draw the overlay image on the canvas
    canvas.drawImage(_overlayImage, Offset(overlayX, overlayY), paint);
  }

  // Finish drawing and create an image
  final ui.Image combinedImage = await recorder.endRecording().toImage(originalImage.width, originalImage.height);

  // Save the combined image to the "Filtered Images" folder
  final directory = await getExternalStorageDirectory();
  final String filteredImagesPath = '${directory!.path}/Filtered Images';
  final String combinedImagePath = '$filteredImagesPath/image_filtered_${DateTime.now()}.png';

  // Create the "Filtered Images" folder if it doesn't exist
  final Directory filteredImagesDir = Directory(filteredImagesPath);
  if (!filteredImagesDir.existsSync()) {
    filteredImagesDir.createSync();
  }

  // Convert the image to bytes and save it as a file
  final ByteData? byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();
  final File file = File(combinedImagePath);
  await file.writeAsBytes(bytes);

  // Display a message to the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Filtered image saved to $combinedImagePath'),
    ),
  );
}

    faceDetector.close();
    setState(() {
      _isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Camera'),
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera),
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final XFile? image = await _controller.takePicture();
              if (image != null) {
                await _detectFacesAndOverlayImage(image);
                final directory = await getExternalStorageDirectory();
                final imagePath =
                    '${directory!.path}/image_${DateTime.now()}.png';
                final File savedImage = File(imagePath);
                await savedImage.writeAsBytes(await image.readAsBytes());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image saved to $imagePath'),
                  ),
                );
              } else {
                print('Error: Captured image is null');
              }
            } catch (e) {
              print('Error: $e');
            }
          },
        )
      );
  }
}
