import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

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

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras![0], // Get the first available camera
      ResolutionPreset.max, // Use the maximum available resolution
    );
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {}); // Refresh the UI when the controller is initialized
    });
  }

  @override
  void dispose() {
    controller?.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  if (controller == null || !controller!.value.isInitialized) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()), // Show loading spinner until the camera is initialized
    );
  }
  return Scaffold(
    body: Stack(
      alignment: Alignment.center,
      children: [
        CameraPreview(controller!), // Display the camera feed
        Positioned(
          top: 50, // Adjust positioning as needed
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
