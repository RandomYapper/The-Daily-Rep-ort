import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:gym_app_flutter/core/constants.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  Map<String, double> nutlist = Map<String, double>.from(defaultNutrients);

  @override
  void initState() {
    super.initState();
    _loadNutrients();
  }

  Future<void> _loadNutrients() async {
    nutlist = await setNutrients(nutlist);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.90),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 38),
                Text(
                  "MACRO TRACKER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.white30,
                        blurRadius: 7,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  width: 66,
                  height: 3.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: const [
                        Colors.white,
                        Colors.grey,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white.withOpacity(0.045),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  child: Column(
                    children: [
                      Text(
                        "Today's Macros",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.93),
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_rounded, color: Colors.white70, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Macro list in glassy cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: nutlist.entries.map((entry) {
                    return Card(
                      color: Colors.white.withOpacity(0.08),
                      elevation: 3.5,
                      shadowColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.white24, width: 1.1),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _iconForMacro(entry.key),
                          color: Colors.white70,
                          size: 26,
                        ),
                        title: Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        trailing: Text(
                          "${entry.value.toStringAsFixed(1)} g",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Stay on track! Eat well. Log every meal.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white38,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Optional: define icons for different macros
  IconData _iconForMacro(String macro) {
    switch (macro.toLowerCase()) {
      case 'protein':
        return Icons.fitness_center;
      case 'carbs':
        return Icons.local_pizza;
      case 'fat':
        return Icons.opacity;
      case 'fiber':
        return Icons.eco_outlined;
      case 'sugar':
        return Icons.cake_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }
}
Future<Map<String, double>> setNutrients(Map<String, double> nutlist) async {
  var food_box = await Hive.openBox('Logged_foods');
  DateTime now = DateTime.now();

  for (var entry in food_box.keys) {
    try {
      DateTime entryTime = DateTime.parse(entry);

      bool isToday = entryTime.year == now.year &&
          entryTime.month == now.month &&
          entryTime.day == now.day;

      if (isToday) {
        Map<String, double> nutrients = Map<String, double>.from(food_box.get(entry));

        for (var macro in nutrients.entries) {
          if (macro.value != 0.0) {
            nutlist[macro.key] = (nutlist[macro.key] ?? 0.0) + macro.value;
          }
        }
        debugPrint('✅ Logged today at $entry → $nutlist');
      }
    } catch (e) {
      debugPrint('⛔️ Failed to parse date from key: $entry');
    }
  }

  return nutlist;
}
