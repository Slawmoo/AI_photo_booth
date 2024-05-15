/*import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(ImagePreview());

class ImagePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImagePreview(),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'dart:io';
import 'home_for_tab.dart';
import 'tablet_main_app.dart';

class ImagePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: const Text(
              'Hello, User',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainUserScreen(),
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 50,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainUserScreen(),
                    ),
                  );
                },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.print,
                  color: Colors.black,
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
//TU FUNKCIONALNOSTI ZAVRŠAVAJU
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final directory = await getExternalStorageDirectory();
              final imagePath = '${directory!.path}/image_${DateTime.now()}.png';
              final File savedImage = File(imagePath);
              await savedImage.writeAsBytes(await image.readAsBytes());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image saved to $imagePath'),
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(imagePath: imagePath),
                ),
              );
            } else {
              print('Error: Captured image is null');
            }
          } catch (e) {
            print('Error: $e');
          }
        },
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}*/
