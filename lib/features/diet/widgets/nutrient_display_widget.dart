import 'package:flutter/material.dart';

class NutrientDisplayWidget extends StatelessWidget {
  final Map<String, double> nutrients;

  const NutrientDisplayWidget({super.key, required this.nutrients});

  @override
  Widget build(BuildContext context) {
    final nonZeroNutrients = nutrients.entries.where((e) => e.value != 0.0);

    if (nonZeroNutrients.isEmpty) {
      return const Center(
        child: Text(
          "No nutrients found.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: nonZeroNutrients.map((entry) {
        final nutrientName = entry.key.replaceAll('_', ' ').toUpperCase();
        final value = entry.value.toStringAsFixed(1);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.grey[900], // Dark background
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nutrientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70, // Slightly faded white
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
