import 'dart:ui'; // Needed for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:gym_app_flutter/features/workout/view/workout_screen.dart';
import 'package:gym_app_flutter/features/diet/view/diet_screen.dart';
import 'package:gym_app_flutter/features/progress/view/progress_screen.dart';
import 'package:gym_app_flutter/features/Track/view/track_screen.dart';
import 'package:gym_app_flutter/features/Profile/profileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    WorkoutScreen(),
    DietScreen(),
    ProgressScreen(),
    TrackScreen(),
    Profilescreen(),
  ];

  final List<String> _titles = [
    'Workout',
    'Diet',
    'Progress',
    'Track',
    'Profile'
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Let appBar float above
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: ClipRRect(
          // For rounded appbar corners if desired
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: Stack(
            children: [
              // Blurred background effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 18),
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.98),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // AppBar content
              Container(
                height: 78,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 32, 18, 6),
                      child: Text(
                        _titles[_selectedIndex].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 5,
                          shadows: [
                            Shadow(
                                color: Colors.white30,
                                blurRadius: 9,
                                offset: Offset(0,3)
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Accent underline
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      margin: const EdgeInsets.only(bottom: 7),
                      width: 34 + (_titles[_selectedIndex].length * 6).toDouble(),
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.10),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: const [Colors.white, Colors.deepPurpleAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.92),
        elevation: 18,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedFontSize: 15,
        unselectedFontSize: 13,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        showUnselectedLabels: true,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later_outlined),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
