import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:gym_app_flutter/core/constants.dart';
import 'package:gym_app_flutter/features/diet/widgets/nutrient_display_widget.dart';
import 'package:gym_app_flutter/features/diet/widgets/diet_log_button.dart';
import 'package:hive/hive.dart';

class OCRPage extends StatefulWidget {
  final File imageFile;
  const OCRPage({super.key, required this.imageFile});

  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  String scannedText = '';
  bool isLoading = true;
  bool success = false;
  final nutrients = Map<String,double>.from(defaultNutrients);

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 OCRPage.initState()'); // <— confirm page load
    _performOCR();

  }

  Future<void> _performOCR() async {
    debugPrint('▶️ Starting OCR on: ${widget.imageFile.path}');
    try {
      final inputImage = InputImage.fromFile(widget.imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      debugPrint('✅ OCR succeeded, text length=${recognizedText.text.length}');
      // PREP: Prepare a list of all lines with position info
      final List<TextLine> lineObjects = [];
      for (final block in recognizedText.blocks) {
        lineObjects.addAll(block.lines);
      }

      // SORT: Sort lines top-to-bottom, then left-to-right (row-wise)
      const rowThreshold = 15.0; // Tweak this based on your image/scanned font
      lineObjects.sort((a, b) {
        if ((a.boundingBox.top - b.boundingBox.top).abs() < rowThreshold) {
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        }
        return a.boundingBox.top.compareTo(b.boundingBox.top);
      });

      // EXTRACT: Parse nutrients from the sorted lines
      for (int i = 0; i < lineObjects.length; i++) {
        final lineText = lineObjects[i].text.toLowerCase().trim();
        for (var nutrient in nutrients.keys) {
          final displayName = nutrient.replaceAll('_', ' ');
          // Try standard regex (nutrient name + value on same line)
          final regex = RegExp('$displayName[^0-9]*([0-9]+(?:\\.[0-9]+)?)');
          final match = regex.firstMatch(lineText);
          if (match != null && (nutrients[nutrient] == defaultNutrients[nutrient])) {
            nutrients[nutrient] = double.tryParse(match.group(1)!) ?? 0.0;
            continue;
          }
          // If not found, but line is exactly the nutrient name...
          if (lineText == displayName && i + 1 < lineObjects.length) {
            final nextLine = lineObjects[i + 1].text.trim();
            // If next line is just a number, use it
            final numberMatch = RegExp(r'^([0-9]+(?:\.[0-9]+)?)$').firstMatch(nextLine);
            if (numberMatch != null && (nutrients[nutrient] == defaultNutrients[nutrient])) {
              nutrients[nutrient] = double.tryParse(numberMatch.group(1)!) ?? 0.0;
            }
          }
        }
      }




      debugPrint('🍽 Extracted nutrients: $nutrients');
      debugPrint('EXTRACTED TEXT (row-wise): \n' +
          lineObjects.map((l) => l.text).join('\n'));
      setState(() {
        scannedText = lineObjects.map((l) => l.text).join('\n');
        isLoading = false;
        success = true;
      });
    } catch (e, st) {
      debugPrint('❌ OCR error: $e\n$st');
      setState(() {
        scannedText = 'Error during OCR:\n$e';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 OCRPage.build() — isLoading=$isLoading');
    return Scaffold(
      appBar: AppBar( title: Text("Scanned Nutrients"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(widget.imageFile, height: 200),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(child: NutrientDisplayWidget(nutrients: nutrients)),
            DietLogButton(label: "Add?", onPressed: ()async{
                    debugPrint('This ran and data type is');
                    var logged_foods = await Hive.openBox('Logged_foods');
                    logged_foods.put(DateTime.now().toString(),
                      nutrients
                    );
                    print(logged_foods.values);
            })
          ],
        ),
      ),
    );
  }

}
