import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetection extends StatefulWidget {
  const PoseDetection({super.key});

  @override
  State<PoseDetection> createState() => _PoseDetectionState();
}

class _PoseDetectionState extends State<PoseDetection> {
  File? _imageFile;
  List<Pose>? _poses;
  ui.Image? _backgroundImage;
  Size? _imageSize;

  final _picker = ImagePicker();
  final _poseDetector = PoseDetector(options: PoseDetectorOptions());

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final inputImage = InputImage.fromFile(imageFile);

    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    final imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

    final poses = await _poseDetector.processImage(inputImage);

    final data = await pickedFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();

    setState(() {
      _imageFile = imageFile;
      _poses = poses;
      _backgroundImage = frame.image;
      _imageSize = imageSize;
    });
  }

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Detection'),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                  child: Text(
                    "Pick Image",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 24),
              if (_backgroundImage != null && _poses != null && _imageSize != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _backgroundImage!.width.toDouble(),
                      height: _backgroundImage!.height.toDouble(),
                      child: CustomPaint(
                        painter: PosePainter(_backgroundImage!, _poses!, _imageSize!),
                      ),
                    ),
                  ),
                )
              else if (_imageFile == null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No image selected.",
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_imageFile != null && (_poses == null || _backgroundImage == null))
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final ui.Image image;
  final List<Pose> poses;
  final Size imageSize;

  PosePainter(this.image, this.poses, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.lightGreenAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final connections = [
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

    for (final pose in poses) {
      // Draw keypoints
      for (final landmark in pose.landmarks.values) {
        final position = Offset(
          landmark.x * scaleX,
          landmark.y * scaleY,
        );
        canvas.drawCircle(position, 6.0, pointPaint);
      }

      // Draw connections
      for (final pair in connections) {
        final p1 = pose.landmarks[pair[0]];
        final p2 = pose.landmarks[pair[1]];
        if (p1 != null && p2 != null) {
          final offset1 = Offset(p1.x * scaleX, p1.y * scaleY);
          final offset2 = Offset(p2.x * scaleX, p2.y * scaleY);
          canvas.drawLine(offset1, offset2, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
