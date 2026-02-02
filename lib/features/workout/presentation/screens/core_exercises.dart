import 'dart:async';
import 'dart:ui'; // Required for FontFeature
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/core/constants/app_colors.dart';
import 'package:the_fit_xone/core/constants/responsive.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/workout_provider.dart';
import 'workout_summary.dart';

// --- Model (UNCHANGED) ---
class ExerciseModel {
  String name;
  int durationSeconds;
  String videoId;
  bool isExpanded;
  bool isDone;
  bool isTimerRunning;
  int currentSecondsRemaining;
  // ✅ NEW: Track actual time spent on this specific exercise
  int timeSpent;
  Timer? timer;

  ExerciseModel({
    required this.name,
    required this.durationSeconds,
    required this.videoId,
    this.isExpanded = false,
    this.isDone = false,
    this.isTimerRunning = false,
    this.timeSpent = 0, // Default 0
    int? remaining,
  }) : currentSecondsRemaining = remaining ?? durationSeconds;
}

class CoreExercisesScreen extends StatefulWidget {
  const CoreExercisesScreen({super.key});

  @override
  State<CoreExercisesScreen> createState() => _CoreExercisesScreenState();
}

class _CoreExercisesScreenState extends State<CoreExercisesScreen> {

  final List<ExerciseModel> _exercises = [
    ExerciseModel(name: "Push Ups", durationSeconds: 240, videoId: "IODxDxX7oi4"),
    ExerciseModel(name: "Crunches", durationSeconds: 240, videoId: "Xyd_fa5zoEU"),
    ExerciseModel(name: "Squats", durationSeconds: 240, videoId: "aclHkVaku9U"),
    ExerciseModel(name: "Pull Ups", durationSeconds: 240, videoId: "eGo4IYlbE5g"),
    ExerciseModel(name: "Sit Ups", durationSeconds: 240, videoId: "jDwoBqPH0jk"),
  ];

  YoutubePlayerController? _activeController;

  bool get _isFocusMode => _exercises.any((e) => e.isExpanded);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _activeController?.dispose();
    for (var ex in _exercises) {
      ex.timer?.cancel();
    }
    super.dispose();
  }

  // --- Logic (UNCHANGED) ---

  void _toggleExpansion(int index) {
    setState(() {
      for (int i = 0; i < _exercises.length; i++) {
        if (i != index) {
          _exercises[i].isExpanded = false;
          _exercises[i].isTimerRunning = false;
          _exercises[i].timer?.cancel();
        }
      }

      _exercises[index].isExpanded = !_exercises[index].isExpanded;
      _activeController?.dispose();
      _activeController = null;

      if (_exercises[index].isExpanded && !_exercises[index].isDone) {
        _activeController = YoutubePlayerController(
          initialVideoId: _exercises[index].videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
            isLive: false,
            forceHD: false,
            disableDragSeek: true,
          ),
        );
      }
    });
  }

  void _toggleTimer(int index) {
    setState(() {
      var ex = _exercises[index];
      ex.isTimerRunning = !ex.isTimerRunning;

      if (ex.isTimerRunning) {
        ex.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            // 1. Increment Active Time
            ex.timeSpent++;

            // 2. Decrement Countdown
            if (ex.currentSecondsRemaining > 0) {
              ex.currentSecondsRemaining--;
            } else {
              ex.timer?.cancel();
              ex.isTimerRunning = false;
              _markDone(index);
            }
          });
        });
      } else {
        ex.timer?.cancel();
      }
    });
  }

  void _markDone(int index) {
    setState(() {
      _exercises[index].isDone = true;
      _exercises[index].isExpanded = false;
      _exercises[index].timer?.cancel();
      _exercises[index].isTimerRunning = false;
      _activeController?.dispose();
      _activeController = null;
    });
  }

  void _navigateToSummary() async {
    final completedList = _exercises.where((e) => e.isDone).toList();

    if (completedList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete at least one exercise!")),
      );
      return;
    }

    // --- FIX 1: Calculate Total Active Time instead of "Screen Open Time" ---
    // We sum up the 'timeSpent' of all exercises.
    // If user clicked DONE without timer, we add a minimum of 1 sec so it's not 0.
    int activeDuration = _exercises.fold(0, (sum, ex) => sum + (ex.timeSpent > 0 ? ex.timeSpent : (ex.isDone ? 1 : 0)));

    // --- FIX 2: Remove the 10-second minimum limit ---
    // Now it allows anything > 0.
    final int finalDuration = activeDuration > 0 ? activeDuration : 1;

    final completedNames = completedList.map((e) => e.name).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
    );

    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final workout = await provider.finishWorkout(
      type: "Core Exercises",
      durationSeconds: finalDuration,
      coreExercises: completedNames,
    );

    if (mounted) Navigator.pop(context);

    if (workout != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(
            workoutType: "Core Exercises",
            totalTime: Duration(seconds: finalDuration),
            completedCoreExercises: completedList,
            caloriesBurned: workout.caloriesBurned,
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned(
            top: 0, left: 0, right: 0,
            height: responsive.hp(35),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/core_power.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        AppColors.scaffoldBackground,
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. MAIN SHEET
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            top: _isFocusMode ? responsive.hp(15) : responsive.hp(25),
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(responsive.wp(8)),
                  topRight: Radius.circular(responsive.wp(8)),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 25,
                      offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: responsive.hp(1.5)),

                  // Drag Handle
                  Container(
                    width: responsive.wp(12),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  SizedBox(height: responsive.hp(2)),

                  // HEADER INFO
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isFocusMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    secondChild: const SizedBox.shrink(),
                    firstChild: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.wp(6), vertical: responsive.hp(1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Core Exercises",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: responsive.hp(3.0),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans')),
                              SizedBox(height: responsive.hp(0.5)),
                              Text("High Intensity",
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: responsive.hp(1.8))),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: responsive.wp(4), vertical: responsive.hp(1)),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                            child: Text("20 min",
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.hp(1.8))),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // EXERCISE LIST (Added Bouncing Physics)
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(), // Premium feel
                      padding: EdgeInsets.fromLTRB(responsive.wp(6), responsive.hp(2), responsive.wp(6), responsive.hp(10)),
                      itemCount: _exercises.length,
                      separatorBuilder: (context, index) => SizedBox(height: responsive.hp(2)),
                      itemBuilder: (context, index) => _buildExerciseCard(responsive, index),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. TOP NAVIGATION
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(5), vertical: responsive.hp(2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(responsive, icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                    _buildFinishButton(responsive),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Styled Helpers ---

  Widget _buildGlassButton(Responsive responsive, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: responsive.hp(5.5),
            width: responsive.hp(5.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: responsive.hp(2.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton(Responsive responsive) {
    return GestureDetector(
      onTap: _navigateToSummary,
      child: Container(
        height: responsive.hp(5.5),
        padding: EdgeInsets.symmetric(horizontal: responsive.wp(5)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.mutedOrange, Color(0xFFFF8A65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: AppColors.mutedOrange.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              "Finish",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.hp(1.8)),
            ),
            SizedBox(width: responsive.wp(2)),
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: responsive.hp(2.2))
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Responsive responsive, int index) {
    final ExerciseModel ex = _exercises[index];
    final bool isActive = ex.isExpanded;

    // Added visual cue for completion (opacity)
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: ex.isDone ? 0.6 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic, // Smoother curve
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF25252A) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? AppColors.primary.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
              width: 1),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 5))]
              : [],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: ex.isDone ? null : () => _toggleExpansion(index),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.wp(5), vertical: responsive.hp(2.5)),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(responsive.wp(3)),
                      decoration: BoxDecoration(
                        color: ex.isDone ? Colors.green.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ex.isDone ? Icons.check_rounded : Icons.fitness_center_rounded,
                        color: ex.isDone ? Colors.green : AppColors.primary,
                        size: responsive.hp(2.5),
                      ),
                    ),
                    SizedBox(width: responsive.wp(4)),
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.name,
                              style: TextStyle(
                                  color: ex.isDone ? Colors.white54 : Colors.white,
                                  fontSize: responsive.hp(2.1),
                                  decoration: ex.isDone ? TextDecoration.lineThrough : null, // Strikethrough if done
                                  decorationColor: Colors.white38,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: responsive.hp(0.5)),
                          Text(
                            ex.isDone ? "Completed" : "Target: 4 mins",
                            style: TextStyle(
                                color: ex.isDone ? Colors.green : Colors.white38,
                                fontSize: responsive.hp(1.6)),
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    if (!ex.isDone)
                      AnimatedRotation(
                        turns: isActive ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: responsive.hp(3)),
                      ),
                  ],
                ),
              ),
            ),

            // Expanded Content
            AnimatedCrossFade(
              firstChild: Container(height: 0),
              secondChild: isActive && _activeController != null ? _buildExpandedBody(responsive, index) : Container(height: 0),
              crossFadeState: isActive ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBody(Responsive responsive, int index) {
    final ExerciseModel ex = _exercises[index];
    // Calculate progress for the bar (0.0 to 1.0)
    final double progress = ex.currentSecondsRemaining / ex.durationSeconds;

    return Padding(
      padding: EdgeInsets.fromLTRB(responsive.wp(4), 0, responsive.wp(4), responsive.hp(3)),
      child: Column(
        children: [
          Divider(color: Colors.white10, height: responsive.hp(2)),

          // Video Player
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _activeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                bottomActions: const [],
              ),
            ),
          ),

          SizedBox(height: responsive.hp(1)),

          // NEW: Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),

          SizedBox(height: responsive.hp(2)),

          // Timer (Dynamic Color)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              // Change color to Primary when running!
              color: ex.isTimerRunning ? AppColors.primary : Colors.white,
              fontSize: responsive.hp(6.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child: Text(_formatTime(ex.currentSecondsRemaining)),
          ),

          SizedBox(height: responsive.hp(3)),

          // Controls
          Row(
            children: [
              // Start/Pause
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: responsive.hp(6.5),
                  child: ElevatedButton(
                    onPressed: () => _toggleTimer(index),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ex.isTimerRunning
                              ? [AppColors.warning, Colors.orangeAccent]
                              : [AppColors.primary, const Color(0xFF6C63FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(ex.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                            SizedBox(width: responsive.wp(2)),
                            Text(
                              ex.isTimerRunning ? "PAUSE" : (ex.currentSecondsRemaining < ex.durationSeconds ? "RESUME" : "START"),
                              style: TextStyle(
                                  fontSize: responsive.hp(1.8),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.wp(3)),

              // Done
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: responsive.hp(6.5),
                  child: OutlinedButton(
                    onPressed: () => _markDone(index),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("DONE",
                        style: TextStyle(
                            fontSize: responsive.hp(1.8),
                            fontWeight: FontWeight.bold,
                            color: Colors.white70)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}