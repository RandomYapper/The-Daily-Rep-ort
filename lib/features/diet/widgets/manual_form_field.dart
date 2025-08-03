import 'package:flutter/material.dart';

class manualFormField extends StatefulWidget {
  final bool isReq;
  final String name;
  final Map<String, double> nutlist;
  const manualFormField({
    super.key,
    required this.isReq,
    required this.name,
    required this.nutlist,
  });

  @override
  State<manualFormField> createState() => _manualFormFieldState();
}

class _manualFormFieldState extends State<manualFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      cursorColor: Colors.white70,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: widget.name,
        hintStyle: TextStyle(color: Colors.white70.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white24, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white24.withOpacity(0.6), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white70, width: 1.8),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: (value) {
        if (widget.isReq && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onSaved: (value) {
        double quantity = double.tryParse(value ?? '') ?? 0.0;
        String foodName = widget.name.toLowerCase().split(" ").join("_");
        widget.nutlist[foodName] = quantity;
        debugPrint('$foodName: $quantity');
      },
    );
  }
}
