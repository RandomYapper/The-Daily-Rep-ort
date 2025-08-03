import 'package:flutter/material.dart';
import 'package:gym_app_flutter/core/constants.dart';
import 'package:gym_app_flutter/features/diet/widgets/manual_form_field.dart';
import 'package:hive/hive.dart';

class manualyAddForm extends StatefulWidget {
  const manualyAddForm({super.key});

  @override
  State<manualyAddForm> createState() => _manualyAddFormState();
}

class _manualyAddFormState extends State<manualyAddForm> {
  final _formGlobalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final nutlist = Map<String, double>.from(defaultNutrients);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.98),
        foregroundColor: Colors.white,
        elevation: 8,
        title: const Text('Add Those Macros!'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 28),
            child: Card(
              color: Colors.white.withOpacity(0.08),
              elevation: 10,
              shadowColor: Colors.white24,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24),
                child: Form(
                  key: _formGlobalKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          colors: [Colors.white, Colors.grey[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(rect),
                        child: const Text(
                          'MACRO ENTRY',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Macro Entry Fields
                      manualFormField(isReq: true, name: "Calories", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Total Carbohydrates", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Protein", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Total Fat", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Saturated Fat", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Trans Fat", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Monosaturated Fat", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Polyunsaturated Fat", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Cholestrol", nutlist: nutlist,),
                      const SizedBox(height: 20),
                      manualFormField(isReq: false, name: "Sodium", nutlist: nutlist,),
                      const SizedBox(height: 26),
                      FilledButton(
                        onPressed: () async {
                          if (_formGlobalKey.currentState!.validate()) {
                            _formGlobalKey.currentState!.save();
                            var box = await Hive.openBox('Logged_foods');
                            final timestampKey = DateTime.now().toString();
                            await box.put(timestampKey, nutlist);
                            debugPrint('Saved to Hive: $timestampKey -> $nutlist');
                            // Optionally: Show a success dialog or pop context!
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Macro entry added!'))
                            );
                            Navigator.of(context).maybePop();
                          }
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 2,
                            ),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                            )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                          child: Text('Add'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: 45,
                        height: 3.2,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}