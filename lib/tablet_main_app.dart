//import 'package:gallery_saver/gallery_saver.dart';
//import 'package:path_provider/path_provider.dart';
/*
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'home_for_tab.dart';
import 'tablet_image_preview.dart';


class MainUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Text(
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
                    builder: (context) => HomeTab(),
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home,
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
}*/
import 'package:flutter/material.dart';
import 'dart:io';
import 'home_for_tab.dart';
import 'tablet_image_preview.dart';

class MainUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Center(
            child: Text(
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
                    builder: (context) => HomeTab(),
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
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle timer button press
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreview(),
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
                        Icons.camera,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Handle flashlight button press
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 100,
              width: MediaQuery.of(context).size.width * 0.425, // Constrain width to show only 5 buttons
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
class MainUserScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  //final CameraDescription camera;

  MainScreen(/*{required this.camera}*/);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await File(image.path).copy(imagePath);

      // Save to gallery
      await GallerySaver.saveImage(newImage.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreview(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Booth'),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.camera),
                  iconSize: 70,
                  onPressed: _takePicture,
                ),
                SizedBox(width: 20),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.timer),
                      iconSize: 40,
                      onPressed: () {
                        // Handle setting a timer
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.flash_on),
                      iconSize: 40,
                      onPressed: () {
                        // Handle toggling flash
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.home),
              iconSize: 40,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeTab()),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  _buildFilterButton('Filter 1'),
                  _buildFilterButton('Filter 2'),
                  _buildFilterButton('Filter 3'),
                  // Add more filters as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filterName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle filter selection
        },
        child: Text(filterName),
      ),
    );
  }
}
*/