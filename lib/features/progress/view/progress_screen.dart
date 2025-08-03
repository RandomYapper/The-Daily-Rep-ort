import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreen();
}

class _ProgressScreen extends State<ProgressScreen> {
  Map<String, double>? nutlist;

  @override
  void initState() {
    super.initState();
    loadNutrients();
  }

  Future<void> loadNutrients() async {
    Map<String, double> finalNutrients = {
      'carbs': 0.0,
      'protein': 0.0,
      'fat': 0.0,
    };

    var foodBox = await Hive.openBox('Logged_foods');
    DateTime now = DateTime.now();

    for (var entry in foodBox.keys) {
      try {
        DateTime entryTime = DateTime.parse(entry);
        bool isToday = entryTime.year == now.year &&
            entryTime.month == now.month &&
            entryTime.day == now.day;

        if (isToday) {
          Map<String, double> loggedNutrients =
          Map<String, double>.from(foodBox.get(entry));

          for (var macro in loggedNutrients.entries) {
            if (macro.value != 0.0) {
              finalNutrients[macro.key] =
                  (finalNutrients[macro.key] ?? 0.0) + macro.value;
            }
          }

          debugPrint('✅ Logged today at $entry → $loggedNutrients');
        }
      } catch (e) {
        debugPrint('⛔️ Failed to parse date from key: $entry');
      }
    }

    setState(() {
      nutlist = finalNutrients;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nutlist == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = (nutlist!['carbs']! + nutlist!['protein']! + nutlist!['fat']!).clamp(1.0, double.infinity);

    // Monochrome shades for carbs, protein, fat
    final colorMap = {
      'carbs': Colors.white70,
      'protein': Colors.white54,
      'fat': Colors.white30,
    };

    final labels = {
      'carbs': 'Carbs',
      'protein': 'Protein',
      'fat': 'Fat',
    };

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nutrient Breakdown'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.2,
          child: Card(
            color: Colors.grey[900]?.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  startDegreeOffset: -90,
                  sections: nutlist!.entries.map((entry) {
                    final value = entry.value.clamp(0.01, double.infinity);
                    final percent = (value / total) * 100;
                    final color = colorMap[entry.key] ?? Colors.white38;
                    final label = labels[entry.key] ?? entry.key;

                    return PieChartSectionData(
                      value: value,
                      color: color,
                      title: '${percent.toStringAsFixed(1)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 6,
                            color: Colors.black54,
                          )
                        ],
                      ),
                      titlePositionPercentageOffset: 0.6,
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (response != null && response.touchedSection != null) {
                        final index = response.touchedSection!.touchedSectionIndex;
                        final selectedMacro = nutlist!.keys.elementAt(index);
                        final amount = nutlist![selectedMacro]!.toStringAsFixed(1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$selectedMacro: $amount g'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                          ),
                        );
                      }
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
