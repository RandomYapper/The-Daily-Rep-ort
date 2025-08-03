import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart'; // For CameraLensDirection
import 'dart:math';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize; // The size of the image from the camera feed (ML Kit's input image size)
  final CameraLensDirection cameraLensDirection;
  final int rotationCompensation; // The rotation compensation calculated in main.dart (0, 90, 180, 270)

  PosePainter(
      this.poses,
      this.absoluteImageSize,
      this.cameraLensDirection,
      this.rotationCompensation,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    final Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..color = Colors.blue;

    for (final pose in poses) {
      // Draw landmarks
      for (final landmark in pose.landmarks.values) {
        final Offset point = _scaleCoordinate(
          landmark.x,
          landmark.y,
          size, // Canvas size (widget size)
          absoluteImageSize, // Original image size (ML Kit input size)
          cameraLensDirection,
          rotationCompensation,
        );
        canvas.drawCircle(point, 4, dotPaint);
      }

      // Draw connections (skeleton)
      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;

        final Offset point1 = _scaleCoordinate(
          joint1.x,
          joint1.y,
          size,
          absoluteImageSize,
          cameraLensDirection,
          rotationCompensation,
        );
        final Offset point2 = _scaleCoordinate(
          joint2.x,
          joint2.y,
          size,
          absoluteImageSize,
          cameraLensDirection,
          rotationCompensation,
        );
        canvas.drawLine(point1, point2, paintType);
      }

      // Arms
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint);

      // Torso
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);

      // Legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paint);

      // Feet (optional, ML Kit also provides these)
      paintLine(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel, paint);
      paintLine(PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex, paint);
      paintLine(PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel, paint);
      paintLine(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex, paint);

      // Head (optional)
      paintLine(PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner, paint);
      paintLine(PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye, paint);
      paintLine(PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter, paint);
      paintLine(PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar, paint);

      paintLine(PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner, paint);
      paintLine(PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, paint);
      paintLine(PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, paint);
      paintLine(PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar, paint);

      paintLine(PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.cameraLensDirection != cameraLensDirection ||
        oldDelegate.rotationCompensation != rotationCompensation;
  }

  // Unified function to transform ML Kit coordinates to Flutter canvas coordinates
  Offset _scaleCoordinate(
      double x,
      double y,
      Size canvasSize, // The size of the CustomPaint widget
      Size imageSize, // The size of the raw camera image (ML Kit's input)
      CameraLensDirection cameraLensDirection,
      int rotationCompensation,
      ) {
    // 1. Apply rotation compensation to the ML Kit coordinates
    double rotatedX = x;
    double rotatedY = y;

    switch (rotationCompensation) {
      case 90:
        rotatedX = imageSize.height - y; // New X is old Y, from bottom
        rotatedY = x;                   // New Y is old X
        break;
      case 180:
        rotatedX = imageSize.width - x;  // New X is old X, mirrored
        rotatedY = imageSize.height - y; // New Y is old Y, mirrored
        break;
      case 270:
        rotatedX = y;                   // New X is old Y
        rotatedY = imageSize.width - x; // New Y is old X, from right
        break;
      case 0:
      default:
      // No rotation, use original x, y
        break;
    }

    // 2. Apply mirroring for front camera after rotation
    if (cameraLensDirection == CameraLensDirection.front) {
      rotatedX = imageSize.width - rotatedX;
    }

    // 3. Scale the rotated and mirrored coordinates to fit the canvas size
    // Note: The scaling should be done relative to the *original* image dimensions.
    // However, if the camera preview itself is fitted to the screen, the aspect ratio
    // might be maintained. We need to be careful with how the preview scales.

    // Calculate scaling factors based on the canvas size and the original image size
    // Assuming the CameraPreview maintains its aspect ratio and fills the available space,
    // we need to find the effective scale factor.
    // The camera image's aspect ratio might be different from the screen's aspect ratio.

    // Determine which dimension (width or height) is the constraining factor for scaling
    // to match how CameraPreview typically scales to fill its parent.
    double scale = min(
      canvasSize.width / imageSize.width,
      canvasSize.height / imageSize.height,
    );

    // If the preview itself is stretched or cropped (e.g., using Boxfit.fill or Boxfit.cover in CameraPreview)
    // then the scaling might be simpler (canvasWidth/imageWidth, canvasHeight/imageHeight).
    // For `Transform.scale` with `AspectRatio` as in `main.dart`, the preview will fill the screen
    // but maintain aspect ratio, which means one dimension might be slightly off the canvas edge.

    // A more accurate scaling for CameraPreview with aspect ratio:
    // The `_cameraController.value.previewSize` is the native resolution of the camera.
    // The `canvasSize` is the size of the `CustomPaint` widget.
    // We want to map `(rotatedX, rotatedY)` from `imageSize` to `canvasSize`.

    double mappedX = rotatedX * (canvasSize.width / imageSize.width);
    double mappedY = rotatedY * (canvasSize.height / imageSize.height);

    return Offset(mappedX, mappedY);
  }
}