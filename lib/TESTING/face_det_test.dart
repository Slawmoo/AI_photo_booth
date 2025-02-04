import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    final options = FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.1,
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

