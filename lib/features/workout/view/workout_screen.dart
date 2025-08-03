import 'package:flutter/material.dart';
import 'package:gym_app_flutter/features/workout/view/camera_preview.dart';
import 'package:gym_app_flutter/features/workout/view/camera_streaming.dart';
import 'package:gym_app_flutter/features/workout/view/detection.dart';
import 'package:gym_app_flutter/main.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Deep black main background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main "Workout" Card
                Card(
                  color: Colors.white.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.white24, width: 1.2)
                  ),
                  elevation: 8,
                  shadowColor: Colors.white24,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'WORKOUT CENTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.96),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Choose a workout mode below',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Detection/Open Button
                        Card(
                          color: Colors.black,
                          elevation: 6,
                          shadowColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                            leading: Icon(Icons.visibility, color: Colors.white70, size: 30),
                            title: Text(
                              "Pose Detector",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.white54),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PoseDetection()));
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pushups Button
                        Card(
                          color: Colors.black,
                          elevation: 6,
                          shadowColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                            leading: Icon(Icons.fitness_center, color: Colors.white70, size: 30),
                            title: Text(
                              "Push-Ups",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.white54),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LivePosePage()));
                            },
                          ),

                        ),
                        const SizedBox(height: 12,),
                        Card(
                          color: Colors.black,
                          elevation: 6,
                          shadowColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                            leading: Icon(Icons.fitness_center, color: Colors.white70, size: 30),
                            title: Text(
                              "Squats",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.white54),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LivePosePage()));
                            },
                          ),

                        ),

                        // Optionally, add a subtle divider or decorative line
                        const SizedBox(height: 26),
                        Container(
                          width: 64,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 2),


                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
