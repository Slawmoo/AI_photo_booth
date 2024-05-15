import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Streaming App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraStreamPage(scaffoldKey: scaffoldKey),
    );
  }
}

class CameraStreamPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  CameraStreamPage({required this.scaffoldKey});

  @override
  _CameraStreamPageState createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  late CameraHandler _cameraHandler;

  @override
  void initState() {
    super.initState();
    _cameraHandler = CameraHandler(context);

    // Run tests
    testCameraInitialization(context, _cameraHandler);
    testFrameCapture(context, _cameraHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(title: Text('Streaming Camera Feed')),
      body: const Center(child: Text('Streaming camera feed...')),
    );
  }

  @override
  void dispose() {
    _cameraHandler.dispose();
    super.dispose();
  }
}

class CameraHandler {
  final BuildContext context;
  late CameraController cameraController;
  Socket? socket;
  bool isInitialized = false;

  CameraHandler(this.context);

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await cameraController.initialize();
    isInitialized = true;
    cameraController.startImageStream(sendFrame);
  }

  void connectAndStart(String ip, int port) async {
    try {
      socket = await Socket.connect(ip, port, timeout: Duration(seconds: 5));
      showSnackbar(context, 'Connected to: ${socket!.remoteAddress.address}:${socket!.port}');
      await initializeCamera();
    } catch (e) {
      showSnackbar(context, 'Failed to connect: $e');
    }
  }

  void sendFrame(CameraImage cameraImage) async {
    if (!isInitialized || socket == null) return;

    final image = await convertYUV420toImage(cameraImage);
    final jpeg = imglib.encodeJpg(image, quality: 70);

    socket!.add(jpeg);
    await socket!.flush();
  }

  Future<imglib.Image> convertYUV420toImage(CameraImage image) async {
    var img = imglib.Image(width: image.width,height: image.height);
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final uvIndex = (y >> 1) * (image.width >> 1) + (x >> 1);
        final index = y * image.width + x;

        final yValue = yPlane[index];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];
        final color = yuvToRgb(yValue, uValue, vValue);
        img.setPixelRgba(x, y, color[0], color[1], color[2],0);
      }
    }
    return img;
  }

  List<int> yuvToRgb(int y, int u, int v) {
    int r = (y + 1.402 * (v - 128)).clamp(0, 255).toInt();
    int g = (y - 0.344136 * (u - 128) - 0.714136 * (v - 128)).clamp(0, 255).toInt();
    int b = (y + 1.772 * (u - 128)).clamp(0, 255).toInt();
    return [r, g, b];
  }

  void showSnackbar(BuildContext context, String message) {
    var snackbar = SnackBar(content: Text(message), duration: Duration(seconds: 4));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void dispose() {
    cameraController.dispose();
    socket?.close();
  }
}

void testCameraInitialization(BuildContext context, CameraHandler cameraHandler) async {
  await cameraHandler.initializeCamera();
  final message = cameraHandler.isInitialized ? "Camera initialization test passed." : "Camera is not initialized.";
  showSnackbar(context, message);
}

void testFrameCapture(BuildContext context, CameraHandler cameraHandler) async {
  final cameras = await availableCameras();
  final cameraController = CameraController(cameras.first, ResolutionPreset.medium);
  await cameraController.initialize();

  cameraController.startImageStream((CameraImage image) async {
    final img = await cameraHandler.convertYUV420toImage(image);
    final message = (img.width == image.width && img.height == image.height) ? "Frame capture and conversion test passed." : "Frame conversion failed.";
    showSnackbar(context, message);
  });
}

void showSnackbar(BuildContext context, String message) {
  var snackbar = SnackBar(content: Text(message), duration: Duration(seconds: 4));
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
