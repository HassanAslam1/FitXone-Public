FitXone – AI-Powered Smart Fitness Ecosystem 📱💪

FitXone is an advanced, AI-powered mobile fitness application built using Flutter and structured around Clean Architecture principles.
Unlike traditional fitness trackers, FitXone combines real-time geolocation services with Grok AI (xAI) to deliver intelligent, context-aware health insights and an enhanced workout experience.
Developed by Muhammad Hassan Aslam
FitXone Technologies
🚀 Key Features
📍 Real-Time Gym Finder
Integrated with Google Places API and Geolocator.
Automatically discovers open gyms within a 5 km radius of the user.
Provides turn-by-turn navigation along with a Bird’s-Eye map view for better spatial awareness.
🧠 AI-Driven Health Insights
Powered by Grok AI (xAI).
Analyzes user biometric data (height and weight) rather than performing static calculations.
Generates dynamic health summaries, BMI evaluations, and intelligent calorie-burn estimates.
⚡ High-Precision Workout Timer
Built with advanced state management techniques.
Supports background execution, pause, and resume without losing progress.
Ensures accurate workout tracking, even during heavy multitasking or extended sessions.
🔥 Firebase-Powered Backend
Secure Authentication: Email and password-based login system.
Cloud Firestore: Real-time data storage for workout history and seamless profile synchronization across devices.
🛠️ Technology Stack
Framework: Flutter & Dart
Architecture: Clean Architecture (Separation of Concerns)
State Management: Provider
Backend Services: Firebase Authentication & Cloud Firestore
APIs: Google Places API, Grok AI (xAI) API
Development Tools: VS Code, Git, Postman
⚙️ Getting Started
Follow the steps below to run the project locally.
1️⃣ Clone the Repository
git clone https://github.com/HassanAslam1/fitxone.git
cd fitxone
2️⃣ Install Dependencies
flutter pub get
3️⃣ Configure API Keys (Required)
Note: For security reasons, API keys are not included in this public repository.
You must provide your own keys for full functionality.
A. Google Maps API Setup
Open the following file:
lib/features/gym_finder/data/datasources/gym_services.dart
(or check lib/core/ depending on project structure)
Locate the _apiKey variable.
Insert your Google Maps API key:
static const String _apiKey = 'PASTE_YOUR_GOOGLE_MAPS_KEY_HERE';
B. Grok AI (xAI) API Setup
Open the following file:
lib/features/workout/data/repositories/workout_repository.dart
Locate the _grokApiKey variable.
Insert your xAI (Grok) API key:
static const String _grokApiKey = 'PASTE_YOUR_GROK_API_KEY_HERE';
4️⃣ Run the Application
flutter run
🔮 Future Roadmap
Wearable Integration: Sync heart-rate and activity data from smartwatches.
Social Leaderboards: Competitive fitness challenges and progress comparison with friends.
Advanced AI Coaching: Personalized workout and fitness plans generated from historical user data.
📬 Contact
Muhammad Hassan Aslam
Flutter Developer | Computer Science Undergraduate
🔗 LinkedIn:  https://www.linkedin.com/in/muhammad-hassan-aslam-aa14772a6/
🌐 Portfolio: hassanaslam.netlify.app
