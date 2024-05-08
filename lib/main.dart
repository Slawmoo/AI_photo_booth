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
      return const Center(child: CircularProgressIndicator()); // Show loading spinner until the camera is initialized
    }
    return Scaffold(
      appBar: AppBar(title: Text('Camera Feed')),
      body: Stack(
        children: <Widget>[
          CameraPreview(controller!), // Display the camera feed
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final imagePath = await takePicture();
                if (imagePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imagePath: imagePath),
                    ),
                  );
                }
              },
              tooltip: 'Take Picture',
              child: Icon(Icons.camera_alt),
            ),
          )
        ],
      ),
      // This will remove the status bar
      extendBodyBehindAppBar: true,
    );
  }

  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: select a camera first.'))
      );
      return null;
    }
    try {
      final image = await controller!.takePicture();
      return image.path;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e'))
      );
      return null;
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
