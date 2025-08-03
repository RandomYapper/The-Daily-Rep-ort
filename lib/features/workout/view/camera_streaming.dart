import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class LivePosePage extends StatefulWidget {
  const LivePosePage({super.key});

  @override
  State<LivePosePage> createState() => _LivePosePageState();
}

class _LivePosePageState extends State<LivePosePage> {
  late PoseDetector _poseDetector;
  bool _isDetecting = false;
  List<Pose> _poses = [];
  Size? _imageSize;
  int pushUps = 0;
  Size? _widgetSize;
  CameraController? _cameraController;
  PushupState _currentPushupState = PushupState.up;
  double _leftElbowAngle = 0.0;
  double _rightElbowAngle = 0.0;

  static const double _STRAIGHT_ARM_ANGLE = 160.0;
  static const double _BENT_ARM_ANGLE = 90.0;

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {

      final cameras = await availableCameras();


      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      await _cameraController!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      debugPrint("Failed to initialize camera: $e");
    }
  }

  Future<void> change(CameraController camCon) async {
    if (_cameraController == null) return;
    CameraLensDirection curDir = _cameraController!.description.lensDirection;
    CameraDescription newDes;
    if (curDir == CameraLensDirection.front) {
      var ListDes = await availableCameras();
      newDes = ListDes.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => ListDes.first,
      );
    } else {
      var ListDes = await availableCameras();
      newDes = ListDes.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => ListDes.first,
      );
    }
    await _cameraController!.dispose();

    _cameraController = CameraController(
      newDes,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processCameraImage);

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isDetecting) {
      debugPrint("Already processing, skipping frame...");
      return;
    }

    _isDetecting = true;
    debugPrint("🔄 [Detection] Started processing frame...");

    await Future.delayed(const Duration(milliseconds: 100)); // throttle
    final WriteBuffer buffer = WriteBuffer();

    for (final plane in cameraImage.planes) {
      buffer.putUint8List(plane.bytes);
    }

    final bytes = buffer.done().buffer.asUint8List();
    final imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );
    final widgetSize = context.size ?? Size.zero;
    _widgetSize = widgetSize;
    _imageSize = imageSize;

    final rotation = _cameraController!.description.lensDirection ==
            CameraLensDirection.front
        ? InputImageRotation.rotation180deg
        : InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
        InputImageFormat.nv21;

    debugPrint(
        "📏 [Image Meta] Size: $imageSize, Rotation: $rotation, Format: ${cameraImage.format.raw}");

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);
      debugPrint("Found ${poses.length} poses");
      setState(() => _poses = poses);
    } catch (e) {
      debugPrint("[Pose Detection Error] $e");
    }

    _isDetecting = false;
  }

  void onAnglesCalculated(double leftAngle, double rightAngle) {
    if (mounted) {
      setState(() {
        _leftElbowAngle = leftAngle;
        _rightElbowAngle = rightAngle;
        _checkPushupStatus();
      });
    }
  }


  void _checkPushupStatus() {
    if (_leftElbowAngle < 0 || _rightElbowAngle < 0) {
      debugPrint("Skipping pushup check: Elbows not fully detected.");
      return;
    }

    // Use the minimum angle of the two elbows for the check, as both need to be bent
    double currentElbowBend = min(_leftElbowAngle, _rightElbowAngle);

    switch (_currentPushupState) {
      case PushupState.up:
        // User is in the upright position. Looking for them to start going down.
        if (currentElbowBend < _STRAIGHT_ARM_ANGLE &&
            currentElbowBend > _BENT_ARM_ANGLE) {
          _currentPushupState = PushupState.downward;
          debugPrint("State Change: UP -> DOWNWARD (Arms starting to bend)");
        }
        break;

      case PushupState.downward:
        // User is going down. Looking for them to reach the bottom.
        if (currentElbowBend <= _BENT_ARM_ANGLE) {
          _currentPushupState = PushupState.bottom;
          debugPrint("State Change: DOWNWARD -> BOTTOM (Arms fully bent)");
        } else if (currentElbowBend >= _STRAIGHT_ARM_ANGLE) {
          // If they straightened their arms without reaching bottom, reset to UP
          _currentPushupState = PushupState.up;
          debugPrint(
              "State Change: DOWNWARD -> UP (Arms straightened early, reset)");
        }
        break;

      case PushupState.bottom:
        // User is at the bottom. Looking for them to start coming up.
        if (currentElbowBend > _BENT_ARM_ANGLE &&
            currentElbowBend < _STRAIGHT_ARM_ANGLE) {
          _currentPushupState = PushupState.upward;
          debugPrint(
              "State Change: BOTTOM -> UPWARD (Arms starting to straighten)");
        }
        // If for some reason they go even deeper, stay in bottom state
        break;

      case PushupState.upward:
        // User is coming up. Looking for them to reach the straight arm position.
        if (currentElbowBend >= _STRAIGHT_ARM_ANGLE) {
          setState(() {
            pushUps++; // Increment count only when a full cycle is completed
          });
          _currentPushupState =
              PushupState.up; // Reset to UP for the next pushup
          debugPrint(
              "State Change: UPWARD -> UP (Pushup completed! Total: $pushUps )");
        } else if (currentElbowBend <= _BENT_ARM_ANGLE) {
          // If they went back down without reaching full extension, reset to bottom
          _currentPushupState = PushupState.bottom;
          debugPrint(
              "State Change: UPWARD -> BOTTOM (Arms re-bent, reset to bottom)");
        }
        break;
    }
    debugPrint(
        "Current Pushup State: $_currentPushupState, Elbow Angle: ${currentElbowBend.toStringAsFixed(0)}°");
  }

  @override
  void dispose() {
    print("🧹 [Dispose] Disposing controller & pose detector");
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Center(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Flip the preview if it's front cam
                CameraPreview(_cameraController!),
                if (_imageSize != null)
                  CustomPaint(
                    painter: _PosePainter(
                      _poses,
                      _imageSize!,
                      screenSize, // Ensure this matches display area
                      _cameraController!,
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: FilledButton(
                          onPressed: () {
                            change(_cameraController!);
                          },
                          child: Text('change'),
                        ),
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          '$pushUps',
                          style: TextStyle(fontSize: 100, color: Colors.red),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum PushupState {
  /// User is in the upright position, ready to go down
  up,

  /// User is going down, arms are bending
  downward,

  /// User is at the lowest point of the pushup (or near it)
  bottom,

  /// User is coming back up, arms are straightening
  upward,
}

class _PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size widgetSize;
  final CameraController cameraUsing;


  Function(double, double)? onAnglesCalculated;
  _PosePainter(this.poses, this.imageSize, this.widgetSize, this.cameraUsing);
  double _calculateAngle(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) {
    if (a == null || b == null || c == null) {
      return -1.0; // Indicate that angle cannot be calculated
    }
    final double v1x = a.x - b.x;
    final double v1y = a.y - b.y;

    final double v2x = c.x - b.x;
    final double v2y = c.y - b.y;

    // Dot product of the two vectors
    final double dotProduct = (v1x * v2x) + (v1y * v2y);

    // Magnitudes of the vectors
    final double magV1 = sqrt((v1x * v1x) + (v1y * v1y));
    final double magV2 = sqrt((v2x * v2x) + (v2y * v2y));

    // Avoid division by zero
    if (magV1 == 0 || magV2 == 0) {
      return -1.0;
    }

    // Cosine of the angle
    double cosAngle = dotProduct / (magV1 * magV2);

    // Clamp the value to ensure it's within [-1, 1] to prevent NaN from acos
    cosAngle = cosAngle.clamp(-1.0, 1.0);

    // Angle in radians
    double angleRad = acos(cosAngle);

    // Convert to degrees
    double angleDeg = angleRad * 180 / pi;

    // Often, for body joints, we want the internal angle, which is typically <= 180.
    // If the model gives a reflex angle, adjust it.
    if (angleDeg > 180) {
      angleDeg = 360 - angleDeg;
    }

    return angleDeg;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final previewSize = cameraUsing.value.previewSize;
    debugPrint("🎨 [Painter] Drawing poses...");
    bool isFrontCamera =
        cameraUsing.description.lensDirection == CameraLensDirection.front;
    // Calculate aspect-ratio preserving scale
    final double scaleX = widgetSize.width / previewSize!.height;
    final double scaleY = widgetSize.height / previewSize.height;
    final double scale = min(scaleX, scaleY);

    // How much empty space is left unused (letterboxing)
    double diffX = widgetSize.width - (previewSize.height * scale);
    double diffY = widgetSize.height - (previewSize.width * scale);
// Center the preview on the screen
    double offsetX = diffX / 2;
    double offsetY = diffY / 2;

    final Paint pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final TextPaint textStyle = TextPaint(
      style: const TextStyle(
        color: Colors.yellow,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );

    const List<List<PoseLandmarkType>> connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];
    double? leftElbowAngle;
    double? rightElbowAngle;
    for (final pose in poses) {
      final landmarks = pose.landmarks;
      // Draw lines
      final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = landmarks[PoseLandmarkType.leftWrist];

      if (leftShoulder != null && leftElbow != null && leftWrist != null) {
        leftElbowAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
        debugPrint("Left Elbow Angle: $leftElbowAngle°");
      }

      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = landmarks[PoseLandmarkType.rightWrist];

      if (rightShoulder != null && rightElbow != null && rightWrist != null) {
        rightElbowAngle =
            _calculateAngle(rightShoulder, rightElbow, rightWrist);
        debugPrint("Right Elbow Angle: $rightElbowAngle°");
      }
      for (final pair in connections) {
        final l1 = landmarks[pair[0]];
        final l2 = landmarks[pair[1]];
        if (l1 != null && l2 != null) {
          double x1 = l1.y * scale + offsetX;
          double y1 = l1.x * scale + offsetY;
          double x2 = l2.y * scale + offsetX;
          double y2 = l2.x * scale + offsetY;
          if (!isFrontCamera) {
            x1 = widgetSize.width - (x1);
            x2 = widgetSize.width - (x2);
          }
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
      // Draw points
      for (final lm in landmarks.values) {
        double x = lm.y * scale + offsetX;
        double y = lm.x * scale + offsetY;
        if (!isFrontCamera) {
          x = widgetSize.width - (x);
        }

        canvas.drawCircle(Offset(x, y), 4, pointPaint);
        if (lm.type == PoseLandmarkType.leftElbow && leftElbowAngle != null) {
          textPainter.text = TextSpan(
              text: '${leftElbowAngle.toStringAsFixed(0)}°',
              style: textStyle.style);
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(x + 10, y - 20)); // Offset text from joint
        } else if (lm.type == PoseLandmarkType.rightElbow &&
            rightElbowAngle != null) {
          textPainter.text = TextSpan(
              text: '${rightElbowAngle.toStringAsFixed(0)}°',
              style: textStyle.style);
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(x + 10, y - 20)); // Offset text from joint
        }
      }
    }

    if (onAnglesCalculated != null) {
      onAnglesCalculated!(leftElbowAngle ?? -1.0, rightElbowAngle ?? -1.0);
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter old) => true;
}

class TextPaint {
  final TextStyle style;
  TextPaint({required this.style});
}
