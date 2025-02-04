import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraFaceDetectionWidget extends StatefulWidget {
  @override
  _CameraFaceDetectionWidgetState createState() => _CameraFaceDetectionWidgetState();
}

class _CameraFaceDetectionWidgetState extends State<CameraFaceDetectionWidget> {
  CameraController? _controller;
  List<Face>? _faces;
  late FaceDetectionService _faceDetectionService;
  bool _isDetecting = false;
  late List<CameraDescription> _cameras;
  int _cameraIndex = 0;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetectionService = FaceDetectionService();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );

    await _controller?.initialize();
    _controller?.startImageStream((image) {
      if (_isDetecting) return;
      _isDetecting = true;

      _processCameraImage(image);
    });

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    final faces = await _faceDetectionService.detectFaces(inputImage);

    setState(() {
      _faces = faces;
      _isDetecting = false;
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constrained to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        if (_faces != null)
          CustomPaint(
            painter: FacePainter(_faces!, _controller!),
          ),
      ],
    );
  }
}

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    final options = FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.5,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<List<Face>> detectFaces(InputImage inputImage) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    return faces;
  }

  void dispose() {
    _faceDetector.close();
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final CameraController controller;

  FacePainter(this.faces, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Your painting logic here
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
