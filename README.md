🏋️♂️ The Daily Rep-ort

A beautifully designed black-and-white, glassmorphic Flutter app for tracking workouts, counting push-ups with AI, logging diet with OCR, and managing your own fitness journey.

🚀 Features
Push-Up Counter & Pose Detection:
Uses Google MLKit Pose Detection and live camera streaming; count reps in real time with AI!

Clean Black & White Glass UI:
Sleek frosted cards, bold typography, and elegant gradients throughout.

Diet Logging & Scanning:
Log macros manually or scan nutrition labels with OCR image capture.

Macro and Nutrition Tracker:
Visualize daily macros with beautiful monochrome cards and responsive graphs (PieChart, Bar, etc.).

Progress Analytics:
Track carbs, protein, fat—today’s stats or historical trends—via stunning charts.

User Auth (Firebase-ready):
Secure Sign Up / Sign In flow, with persistent login.

Fully Responsive:
Gorgeous on any device, dark mode by design.

✨ Screenshots
<p align="center"> <img src="assets/screens/workout_card.png" width="240"> <img src="assets/screens/diet_card.png" width="240"> <img src="assets/screens/piechart.png" width="240"> </p> > _Add your own screenshots for a wow effect!_
🛠️ Tech Stack
Flutter (null-safety)

firebase_auth, hive for persistence

google_mlkit_pose_detection (AI fitness!)

fl_chart (beautiful charts)

image_picker, path_provider, and more

⚡️ Getting Started
Clone this repo:

text
git clone https://github.com/yourusername/gym_app_flutter.git
cd gym_app_flutter
Install dependencies:

text
flutter pub get
Configure Firebase:
Add your google-services.json (Android) or GoogleService-Info.plist (iOS) if using authentication.

Run it!

text
flutter run
Tested with Flutter 3.x+ and Dart 3.x

👀 Code Highlights
Modular architecture (features/ folder per module)

All major screens themed for a high-contrast glassy look

Async auth gate: on startup, shows Sign Up page if user not signed in, else jumps to Home

Old-school gym performance meets AI 🤖

📦 Folder Structure
text
lib/
 ├─ core/
 ├─ features/
 │   ├─ home/
 │   ├─ workout/   # Pose detection, camera, push-ups
 │   ├─ diet/      # Log macros, OCR, forms
 │   ├─ progress/  # Charts, tracking
 ├─ main.dart
🖤 Credits
Pose Detection: Google MLKit

Charts: fl_chart

UI Inspiration: Glassmorphism, Apple Fitness, and your imagination!

📝 License
MIT License.
Enjoy your fitness journey, one beautiful push-up at a time!

💡 Star, fork, and PRs welcome!
Let’s get fit with code! 💪

If you want a markdown badge or want to automate screenshots, let me know!
You can further personalize the sections for your team, sponsorship, or deployment links.
