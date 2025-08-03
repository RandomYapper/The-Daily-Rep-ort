import 'package:flutter/material.dart';

class DietLogButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Icon icon;

  const DietLogButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon = const Icon(Icons.add,size: 22,color: Colors.transparent,)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // text & icon color
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
        shadowColor: Colors.white12,
        elevation: 4,
      ),
      child: Row(
        children: [
          Text(label),
          icon
        ],
      ),
    );
  }
}
