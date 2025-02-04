import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final CameraController controller;

  FacePainter(this.faces, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (final face in faces) {
      final rect = _scaleRect(
        rect: face.boundingBox,
        imageSize: Size(
          controller.value.previewSize!.height,
          controller.value.previewSize!.width,
        ),
        widgetSize: size,
      );

      canvas.drawRect(rect, paint);

      // You can draw a picture above the face by loading an image and painting it here
      // For example:
      // final picture = Image.asset('assets/hat.png');
      // canvas.drawImage(picture, Offset(rect.left, rect.top - picture.height), paint);
    }
  }

  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
