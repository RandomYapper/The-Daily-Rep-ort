import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_app_flutter/features/diet/view/manually_add_form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_app_flutter/features/diet/view/ocr_result_screen.dart';
import 'package:gym_app_flutter/features/diet/widgets/diet_log_button.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showImageSourceDialog() {
    debugPrint('Opening image source dialog...');
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.black.withOpacity(0.88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Upload Nutrition Label',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              debugPrint('Camera selected');
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.white),
                SizedBox(width: 10),
                Text('Take a Photo', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              debugPrint('Gallery selected');
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              children: [
                Icon(Icons.photo_library, color: Colors.white),
                SizedBox(width: 10),
                Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('Opening image picker...');
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (!mounted) {
      debugPrint('Widget is no longer mounted.');
      return;
    }

    if (pickedFile != null) {
      debugPrint('Image picked: ${pickedFile.path}');
      final File imageFile = File(pickedFile.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OCRPage(imageFile: imageFile),
        ),
      );
    } else {
      debugPrint('No image selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Main background gradient for dark/contrast look
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 3),
            child: Card(
              color: Colors.white.withOpacity(0.06),
              elevation: 9,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white24, width: 1.1),
              ),
              shadowColor: Colors.white24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Headline text
                    ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [Colors.white, Colors.grey[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(rect),
                      child: const Text(
                        'DIET LOGGING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Wanna log your meal or scan a nutrition label?\nMake it part of your fitness journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Manual add button as a glassy card
                        Flexible(
                          child: Card(
                            color: Colors.black.withOpacity(0.85),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            shadowColor: Colors.white24,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                debugPrint('Manual log pressed');
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>manualyAddForm()));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white.withOpacity(0.96), size: 19),
                                    const SizedBox(width: 2),
                                    const Text(
                                      'Manually',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Scan button as a glassy card
                        Flexible(
                          child: Card(
                            color: Colors.black.withOpacity(0.85),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            shadowColor: Colors.white24,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _showImageSourceDialog,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white.withOpacity(0.96), size: 22),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Scan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 55,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'Stay on track. Eat smart.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.1,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
