import 'dart:async';// Client app for sending saving and sending pictures 
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Fetch available cameras
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(cameras: cameras!),
    );
  }
}

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<File> imagesList = [];
  bool isFlashOn = false;
  bool isRearCamera = true;

  @override
  void initState() {
    super.initState();
    startCamera(isRearCamera ? 0 : 1); // Initialize camera based on the rear camera state
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<File> saveImage(XFile image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downloadPath/$fileName');

    await file.writeAsBytes(await image.readAsBytes());
    MediaScanner.loadMedia(path: file.path); // Ensure the image is visible in the gallery app immediately

    return file;
  }

  void takePicture() async {
    if (!cameraController.value.isInitialized || cameraController.value.isTakingPicture) {
      return; // Guard clause to prevent errors
    }

    final image = await cameraController.takePicture();
    if (isFlashOn) {
      await cameraController.setFlashMode(FlashMode.torch);
    }

    final file = await saveImage(image);
    sendImage(file);
    setState(() {
      imagesList.add(file);
      Timer(Duration(seconds: 1), () {
        cameraController.setFlashMode(FlashMode.off); // Turn off the flash after taking a picture
      });
    });
  }
  void sendImage(File imageFile) async {
  try {
      // Assuming the server IP and port are known and server is listening
      final String serverIp = '192.168.0.3'; // Example IP, adjust accordingly
      final int serverPort = 3000; // Example Port
      final Socket socket = await Socket.connect(serverIp, serverPort);
      showSnackbar(context,'Connected to: ${socket.remoteAddress.address}:${socket.port}');

      List<int> imageBytes = await imageFile.readAsBytes();
      socket.add(imageBytes);
      await socket.flush(); // Sends the data
      socket.close();
      showSnackbar(context,'Image sent!');
    } catch (e) {
      showSnackbar(context,'Error sending image: $e');
    }
  }
  //snackBar popUps for messages
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackbar(BuildContext context, String message) {
  var snackbar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  //endOf snackBars


  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    cameraValue = cameraController.initialize().then((_) {
      setState(() {}); // Refresh UI post camera initialization
    }).catchError((e) {
      showSnackbar(context,'Error initializing camera: $e');

    });
  }


@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey, // for snackBar
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(255, 255, 255, .7),
        shape: const CircleBorder(),
        onPressed: takePicture,
        child: const Icon(
          Icons.camera_alt,
          size: 40,
          color: Colors.black87,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(50, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: isFlashOn
                              ? const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.flash_off,
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRearCamera = !isRearCamera;
                        });
                        isRearCamera ? startCamera(0) : startCamera(1);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(50, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: isRearCamera
                              ? const Icon(
                                  Icons.camera_rear,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.camera_front,
                                  color: Colors.white,
                                  size: 30,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7, bottom: 75),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: imagesList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                height: 100,
                                width: 100,
                                opacity: const AlwaysStoppedAnimation(07),
                                image: FileImage(
                                  File(imagesList[index].path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  
